###
# This importer is intended to run periodically (eg. on the hour). If the period is more than 1 day, you must pass a
# Here's how it works:
#   1. Query AS Solr for resources and digital objects updated (system_mtime) in the past 24 hours
#      a. For resrouces: compare system_mtime with updated_at timestamp for resource in GC database, 
#         and add uri to @update_resource_trees if AS datetime > CG datetime
#      b. For digital objects: get linked_instance_uris and perform a new query for these records. Then, for each record:
#         i. If the record is a resource, repeat 1a
#         ii. If the record is an archival object, compare system_mtime with corresponding record in CG
#             and add resource uri to @update_resource_trees if AS datetime > CG datetime
#   2. Create AspaceImport record (store as @aspace_import), import_type: 'periodic'
#   3. For each URI in @update_resource_trees:
#      a. find_by uri to get resource
#      b. enque UpdateResourceTreeJob, passing resource id and aspace_import id
#   4. Service call is complete when all jobs have been added to the queue. The jobs will update the aspace_import record as needed.
###

class ExecuteAspacePeriodicImport

  include GeneralUtilities

  @@rows = 50


  def self.call(options={})
    object = new(options)
    object.call
  end

  def initialize(options={})
    @options = options
    @response = {}
  end

  def call
    execute
  end


  private


  def execute
    log_info "Running periodic update from ArchivesSpace..."
    @import_type = @options[:import_type] || 'periodic'
    @since = @options[:since] || 25.hours.ago
    # format last_datetime to look like this: 2014-05-21T15:20:37Z
    @since = @since.to_datetime.new_offset(0).strftime('%Y-%m-%dT%H:%M:%SZ')
    @since.gsub!(/\:/,'\:')
    @update_resource_trees = []
    @base_query = "system_mtime:[#{ @since } TO NOW] AND publish:true"

    begin

      process_resources
      process_digital_objects
      @update_resource_trees.uniq!
      @update_resource_trees.delete_if { |x| x.blank? }

      if @update_resource_trees.empty?
        log_info "No required updates were found"
      else
        log_info "#{ @update_resource_trees.length } resources will be updated:"
        log_info "#{ @update_resource_trees.join(', ') }"
      end
      

      @update_resource_trees.each do |uri|
        import_resource(uri)
      end

      # if @total_updates > 0
      #   AspaceImport.create(import_type: @import_type, resources_updated: @resources_updated, import_errors: @errors)
      # end

      log_info "ExecuteAspacePeriodicImport complete"

    rescue Exception => e
      @response = { error: e }
    end
  end


  # system_mtime must be a DateTime, not a String
  # def resource_needs_update?(uri, system_mtime)
  #   if r = Resource.find_by(uri: uri)
  #     u = r.updated_at
  #     system_mtime > u
  #   else
  #     true
  #   end
  # end


  # def archival_object_needs_update?(uri, system_mtime)
  #   if ao = ArchivalObject.find_by(uri: uri)
  #     u = ao.updated_at
  #     system_mtime > u
  #   else
  #     true
  #   end
  # end


  def process_resources
    records = get_updated_records('resource')
    records.each do |r|
      uri = r['id']
      system_mtime = DateTime.parse(r['system_mtime'])
      @update_resource_trees << uri
    end
    @update_resource_trees.uniq!
  end


  def process_digital_objects
    records = get_updated_records('digital_object')
    linked_record_uris = []
    records.each do |r|
      linked_record_uris += r['linked_instance_uris']
    end
    linked_record_uris.uniq!
    uri_batch = []
    linked_record_uris.each_index do |i|
      uri_batch << linked_record_uris[i]
      if i == @@rows - 1
        query = "id:(\"#{uri_batch.join('","')}\")"
        response = AspaceImport.execute_solr_query(query)
        if linked_records = response['response']['docs']
          process_linked_records(linked_records)
        end
        uri_batch = []
      end
    end
  end


  def process_linked_records(records)
    records.each do |r|
      system_mtime = DateTime.parse(r['system_mtime'])
      case r['primary_type']
      when 'resource'
        uri = r['id']
      when 'archival_object'
        uri = r['resource']
      end
      @update_resource_trees << uri
    end
    @update_resource_trees.uniq!
  end


  def get_updated_records(record_type)
    records = []
    query = @base_query + " AND primary_type:#{record_type}"



    case record_type
    when 'resource'
      query += ' AND finding_aid_status:completed'
    when 'archival_object'
      query += ' AND types:(-pui)'
    end

    get_records_from_solr = lambda do |start|
      if start == 0
        puts "*** #{ record_type.gsub(/_/, ' ') } ***"
      end
      response = AspaceImport.execute_solr_query(query, rows: @@rows, start: start)
      num_found = response['response']['numFound']
      records += response['response']['docs']
      if (start + @@rows) < num_found
        get_records_from_solr.call(start + @@rows)
      end
    end

    get_records_from_solr.call(0)

    records
  end


  def import_resource(uri)
    resource_data = Resource.get_data_from_api(uri, @options)
    begin
      log_info "Updating resource tree for #{uri}"

      if resource_data[:finding_aid_status].match(/[Cc]ompleted/) && resource_data[:publish]
        resource = Resource.create_or_update_from_data(resource_data)
        resource.reload
        UpdateResourceTreeJob.perform_later(resource.uri)
        # SearchIndexResourceTreeJob.perform_later(resource.id)
      else
        log_info "*** Resource #{uri} is not published/completed ***"
        @resources_updated -= 1
      end
    rescue Exception => e
      log_info "*** Resource tree update FAILED for #{uri} ***"
      log_info e
      log_info "***"
      @resources_updated -= 1
      @errors += 1
    end
  end

end
