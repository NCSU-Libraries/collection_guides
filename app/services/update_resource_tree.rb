class UpdateResourceTree

  include GeneralUtilities

  def self.call(resource_id)
    object = new(resource_id)
    object.call
  end


  def initialize(resource_id)
    @resource_id = resource_id
    @resource = Resource.find_by(id: resource_id)
    @session = ArchivesSpaceApiUtility::ArchivesSpaceSession.new(read_timeout: 360)
    # track existing components not included in tree response
    @existing_archival_object_ids = @resource.archival_objects.pluck(:id)
    @removed_archival_objects = { unpublished: [], supressed: [], missing: [] }
  end


  def call
    log_info "UpdateResourceTree called for resource id #{ @resource_id }"

    if !@resource
      log_info "Resource does not exist with id #{ @resource_id } ... abortin!"
    else
      update_tree
    end
  end


  private


  def update_tree
    @resource.reload
    tree_response = @session.get("#{@resource.uri}/tree")

    if tree_response.code.to_i == 200
      tree = JSON.parse(tree_response.body)
      resource_children = tree['children']
      update_children(resource_children, nil)

      @removed_archival_objects[:missing] = @existing_archival_object_ids
      @removed_archival_objects.delete_if { |k,v| v.blank? }
      process_removed()

      @resource.reload
      @resource.update_hierarchy_attributes
      @resource.reload
      @resource.update_tree_unit_data
    elsif tree_response.code.to_i == 412
      puts "SESSION LOST - ESTABLISHING NEW"
      @session = ArchivesSpaceApiUtility::ArchivesSpaceSession.new(read_timeout: 360)
      update_tree
    else
      puts "RESPONSE CODE: #{tree_response.code}"
      raise tree_response.body
    end
  end


  def update_children(children, parent_id)
    # base_attrs = { resource_id: @resource_id, parent_id: parent_id, publish: true }
    children.each_index do |i|
      print '.'
      child = children[i]

      # check for !publish or supressed
      if child['publish'] && !child['supressed']
        child_record = ArchivalObject.where(id: child['id']).first

        if child_record
          child_record.update_from_api
        else
          child_record = ArchivalObject.create_from_api(child['record_uri'])
        end

        # Update parent_id here because it is not included in individual responses per archival_object
        child_record.update_attributes(parent_id: parent_id)

        if child['has_children']
          # recursion
          update_children(child['children'], child['id'])
        end

      elsif !child['publish'] && @existing_archival_object_ids.include?(child['id'])
        @removed_archival_objects[:unpublished] << child['id']
      elsif child['supressed'] && @existing_archival_object_ids.include?(child['id'])
        @emoved_archival_objects[:supressed] << child['id']
      end

      @existing_archival_object_ids.delete(child['id'])
    end
    puts
  end


  def process_removed
    resources_to_update = []

    process_archival_object = lambda do |id|
      a = ArchivalObject.find(id)
      a_response = @session.get(a.uri)

      if a_response.code.to_i == 412
        puts "SESSION LOST - ESTABLISHING NEW"
        @session = ArchivesSpaceApiUtility::ArchivesSpaceSession.new(read_timeout: 360)
        process_archival_object.(id)
      elsif a_response.code.to_i == 404
        # archival_object has been deleted
        a.destroy
      elsif a_response.code.to_i == 200
        a_data = JSON.parse(a_response.body)

        if a_data['resource'] && a_data['resource']['ref']
          # archival_object has been moved
          # OR, even worse, it has been deleted from the tree but persists in the AS database.
          a_resource_uri = a_data['resource']['ref']

          if a_resource_uri != @resource.uri
            puts "ArchivalObject #{a.id} (#{a.title}) has moved to #{a_resource_uri}"

            if !Resource.where(uri: a_resource_uri).exists?
              Resource.create_from_api(a_resource_uri)
            end

            resources_to_update << a_resource_uri
          else
            a.update_attributes(resource_id: nil)
          end
        else
          # archival_object has been orphaned
          a.destroy
        end
      end
    end

    @removed_archival_objects.each do |k,v|
      if [:unpublished,:supressed].include?(k)
        ArchivalObject.where("id IN (#{v.join(',')})").each { |a| a.destroy }
      elsif k == :missing
        v.each do |id|
          process_archival_object.(id)
        end

        resources_to_update.uniq!

        if !resources_to_update.blank?
          puts "Tree update required for #{resources_to_update.join(', ')}"

          resources_to_update.each do |resource_uri|
            r = Resource.find_by_uri(resource_uri)
            UpdateResourceTree.call(r.id)
          end
        end
      end
    end
  end

end
