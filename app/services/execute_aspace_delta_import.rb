class ExecuteAspaceDeltaImport

  include GeneralUtilities

  def self.call(options={})
    object = new(options)
    object.call
  end

  def initialize(options)
    @options = options
    @import_type = @options[:import_type] || 'delta'
    @last_datetime = AspaceImport.last_import_date
        # format last_datetime to look like this: 2014-05-21T15:20:37Z
    @since = options[:since] || @last_datetime
    @since = @since.to_datetime.new_offset(0).strftime('%Y-%m-%dT%H:%M:%SZ')
    @since.gsub!(/\:/,'\:')
    @update_resource_trees = []
    @total_resources = Resource.count
    @total_updates = 0
    @resources_updated = 0
    @errors = 0
    @rows = 50
    @base_query = "(user_mtime:[#{ @since } TO NOW] OR system_mtime:[#{ @since } TO NOW]) AND publish:true"
  end

  def call
    execute_delta_import
  end


  private


  def execute_delta_import
    log_info "Executing import of records in ArchivesSpace updated since #{ @since }"

    @digital_object_instance_refs = []

    ['resource', 'archival_object', 'digital_object'].each do |record_type|
      get_updated_records(record_type)
    end

    get_resources_for_digital_objects()

    @update_resource_trees.uniq!
    @update_resource_trees.delete_if { |x| x.blank? }
    @resources_updated += @update_resource_trees.length
    log_info "#{ @resources_updated } resources will be updated:"
    log_info "#{ @update_resource_trees.join(', ') }"

    @update_resource_trees.each do |uri|
      import_resource(uri)
    end

    if @total_updates > 0
      AspaceImport.create(import_type: @import_type, resources_updated: @resources_updated, import_errors: @errors)
    end

    log_info "AspaceImport delta import complete"
  end


  def update_digital_object_instance_refs(response_data)
    data = JSON.parse(response_data['json'])
    data['linked_instances'].each do |i|
      @digital_object_instance_refs << i['ref']
    end
    @digital_object_instance_refs.uniq!
  end


  def get_updated_records(record_type, start=0)
    query = @base_query + " AND primary_type:#{record_type}"

    if start == 0
      puts "*** #{ record_type.gsub(/_/, ' ') } ***"
    end

    case record_type
    when 'resource'
      query += ' AND finding_aid_status:completed'
    when 'archival_object'
      query += ' AND types:(-pui)'
    end

    response = AspaceImport.execute_solr_query(query, rows: @rows, start: start)
    num_found = response['response']['numFound']
    @total_updates += num_found

    response['response']['docs'].each do |d|
      print '.'
      case record_type
      when 'resource'
        @update_resource_trees << d['id']
      when 'archival_object'
        @update_resource_trees << d['resource']
      when 'digital_object'
        update_digital_object_instance_refs(d)
      end
    end
    puts

    @update_resource_trees.uniq!
     # throttle requests
    sleep(1)

    if (start + @rows) < num_found
      get_updated_records(record_type, start + @rows)
    end
  end


  def get_resources_for_digital_objects
    batch = []

    @digital_object_instance_refs.each_index do |i|
      batch << @digital_object_instance_refs[i]

      if (i > 0 && i % 10 == 0) || (i == @digital_object_instance_refs.length - 1)
        query = @base_query.clone
        query += ' AND id:("'
        query += batch.join('","')
        query += '")'

        response = AspaceImport.execute_solr_query(query)
        response['response']['docs'].each do |d|
          if d['resource']
            @update_resource_trees << d['resource']
          end
        end
        batch = []
      end
    end
    @update_resource_trees.uniq!
  end


  def import_resource(uri)
    resource_data = Resource.get_data_from_api(uri, @options)
    begin
      log_info "Updating resource tree for #{uri}"

      if resource_data[:finding_aid_status].match(/[Cc]ompleted/) && resource_data[:publish]
        resource = Resource.create_or_update_from_data(resource_data)
        resource.reload
        UpdateResourceTree.call(resource.id)
        SearchIndexResourceTreeJob.perform_later(resource.id)
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
