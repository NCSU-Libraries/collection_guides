# This is the updated version of UpdateResourceTree, which relied on a deprecated endpoint to retrieve records

class UpdateResourceTreeService

  include GeneralUtilities

  def self.call(resource_uri, options={})
    object = new(resource_uri, options)
    object.call
  end


  def initialize(resource_uri, options={})
    @resource_uri = resource_uri
    @options = options
  end


  def call
    log_info "UpdateResourceTree called for #{ @resource_uri }"
    execute
  end


  private


  def execute

    puts "UpdateResourceTreeService executing"

    @resource = Resource.create_or_update_from_api(@resource_uri)

    @session = ArchivesSpaceApiUtility::ArchivesSpaceSession.new(read_timeout: 360)
    # track existing components not included in tree response
    @existing_archival_object_ids = @resource.archival_objects.pluck(:id)
    @removed_archival_objects = { unpublished: [], supressed: [], missing: [] }

    # Update resource
    @resource.update_from_api

    # Get tree nodes (archival objects) in batches and update each
    update_tree

    # Process archival objects that have been removed or moved to another resource
    # ids are removed from @existing_archival_object_ids as they are processed
    # any that remain were not included in the tree and need to be dealt with (maybe they moved)
    @removed_archival_objects[:missing] = @existing_archival_object_ids
    puts "Processing existing archival object records not longer included in Resource tree:"
    process_removed

    # Update hiearchy attributes of resource
    @resource.reload
    @resource.update_hierarchy_attributes

    # Update unit data (converted API response, optimized for presentation)
    @resource.reload
    @resource.update_tree_unit_data

    puts "performing SearchIndexResourceTreeJob"
    SearchIndexResourceTreeJob.perform_later(@resource.id)

    { resource: @resource }
  end


  def update_tree
    root_data = get_tree_root_data
    process_children(root_data)
  end


  def get_tree_root_data
    path = Pathname.new(@resource_uri) + 'tree/root'
    api_response = @session.get(path.to_s)
    JSON.parse(api_response.body)
  end


  def get_tree_node_data(node_uri)
    path = Pathname.new(@resource_uri) + 'tree/node'
    request_params = { node_uri: node_uri }
    api_response = @session.get(path.to_s, request_params)
    JSON.parse(api_response.body)
  end


  def get_waypoint_children(parent_uri=nil, offset=0)
    params = { offset: offset, parent_node: parent_uri }
    path = Pathname.new(@resource_uri) + 'tree/waypoint'
    api_response = @session.get(path.to_s, params)

    JSON.parse(api_response.body)
  end


  # data is a record that may or may not include precomputed_waypoints
  def process_children(data, parent_uri=nil)
    if data['child_count'] > 0
      if !parent_uri
        parent = @resource
        log_info "Processing children of root (#{@resource_uri})..."
      else
        parent = ArchivalObject.find_by(uri: parent_uri)
        log_info "Processing children of #{parent_uri}..."
      end

      i = 0
      waypoints = data['waypoints']
    
      while i < waypoints
        parent_key = parent_uri || ''
        if data['precomputed_waypoints'] && data['precomputed_waypoints'][parent_key] && data['precomputed_waypoints'][parent_key][i.to_s]
          log_info "Processing precomuted_waypoints..."
          children = data['precomputed_waypoints'][parent_key][i.to_s]
        else
          log_info "Fethcing/processing waypoint #{i} for #{parent_uri || 'root'}..."
          children = get_waypoint_children(parent_uri, i)
        end 

        children.each do |child|
          process_child(child, parent)
        end

        i += 1
      end

    end
  end


  # child is the hash of attributes included for each child in computed waypoints (api response)
  # parent is a Collection Guides ArchivalObject record
  def process_child(child, parent)
    uri = child['uri']
    has_children = child['child_count'] > 0
    # get full AS record to make sure it's published and not supressed
    child_api_response = @session.get(uri)
    child_data = JSON.parse(child_api_response.body)
    child_record = ArchivalObject.find_by(uri: uri)

    if child_data['publish'] && !child_data['supressed']
      if child_record
        child_record.update_from_api
      else
        child_record = ArchivalObject.create_from_api(uri)
      end

      # Update parent_id here because it is not included in individual responses per archival_object
      child_record.update!(parent_id: parent.id) if parent.is_a?(ArchivalObject)

      if has_children
        # recursion
        process_children(child, uri)
      end

    elsif !child_data['publish'] && child_record
      @removed_archival_objects[:unpublished] << child_record.id
    elsif child_data['supressed'] && child_record
      @removed_archival_objects[:supressed] << child_record.id
    end

    if child_record
      @existing_archival_object_ids.delete(child_record.id)
    end
  end


  def process_removed

    puts "Processing ArchivalObject records that are no longer included in resource:"
    puts @removed_archival_objects.inspect

    resources_to_update = []

    process_archival_object = lambda do |id|
      a = ArchivalObject.find(id)

      puts a.inspect

      a_response = @session.get(a.uri)

      puts a_response.code
      puts a_response.body

      if a_response.code.to_i == 412
        log_info "SESSION LOST - ESTABLISHING NEW"
        @session = ArchivesSpaceApiUtility::ArchivesSpaceSession.new(read_timeout: 360)
        process_archival_object.(id)
      elsif a_response.code.to_i == 404
        # archival_object has been deleted
        puts "Deleting ArchivalObject #{a.id}"
        a.destroy
      elsif a_response.code.to_i == 200
        a_data = JSON.parse(a_response.body)

        puts a_data.inspect

        if a_data['resource'] && a_data['resource']['ref']
          # archival_object has been moved
          # OR, even worse, it has been deleted from the tree but persists in the AS database.
          a_resource_uri = a_data['resource']['ref']

          puts "ArchivalObject #{a.id} has moved to #{a_resource_uri}"

          if a_resource_uri != @resource.uri
            log_info "ArchivalObject #{a.id} (#{a.title}) has moved to #{a_resource_uri}"
            r = Resource.find_by(uri: a_resource_uri) || Resource.create_from_api(a_resource_uri)
            # resources_to_update << a_resource_uri
            resource_tree_update = ResourceTreeUpdate.create!(resource_id: r.id, resource_uri: r.uri)
            UpdateResourceTreeJob.perform_later(resource_tree_update)
          else
            a.update!(resource_id: nil)
          end
        else
          # archival_object has been orphaned
          puts "Deleting ArchivalObject #{a.id}"
          a.destroy
        end
      end

    end


    @removed_archival_objects.each do |k,v|
      puts k
      case k
      when :unpublished,:supressed
        if !v.empty?
          puts "Deleting unpublished and supressed ArchivalObjects:"
          puts v.inspect
          
          ArchivalObject.where("id IN (#{v.join(',')})").each do |a|
            puts "Deleting ArchivalObject #{a.id}"
            a.destroy
          end
        end
      when :missing
        puts "Deleting ArchivalObjects that no longer exist in this resource:"
        puts v.inspect
        puts v.length

        v.each do |id|
          puts "processing ArchivalObject #{id}"
          process_archival_object.call(id)
        end
      end
    end


    # resources_to_update.uniq!

    # if !resources_to_update.blank?
    #   puts "Tree update required for #{resources_to_update.join(', ')}"

    #   resources_to_update.each do |resource_uri|
    #     # r = Resource.find_by_uri(resource_uri)
    #     UpdateResourceTreeService.call(resource_uri)
    #   end
    # end


  end

end
