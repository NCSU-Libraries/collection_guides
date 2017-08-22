class AspaceImport < ActiveRecord::Base

  require 'modules/general_utilities.rb'
  include GeneralUtilities

  # Import all records from ArchivesSpace
  def self.execute_full(options={})

    Rails.logger.info "AspaceImport.execute_full called"

    options[:session] ||= ArchivesSpaceApiUtility::ArchivesSpaceSession.new
    session = options[:session]
    options[:update_start] ||= DateTime.now.to_formatted_s(:db)
    page = options[:page] || 1
    last_page = nil
    page_size = 10
    puts "Importing resources and resource trees..."
    @resources_updated = 0

    Repository.find_each do |repo|

      path = "/repositories/#{repo.id}/resources"

      # make initial request to get total pages:
      response = session.get(path, page: page, page_size: page_size)
      if response.code.to_i == 200
        response = JSON.parse(response.body)
        last_page ||= response['last_page']
      end

      options = {
        page: page,
        page_size: page_size,
        path: path,
      }

      while options[:page] <= last_page

        # re-establish sesssion for each page to avoid timeouts
        options[:session] = ArchivesSpaceApiUtility::ArchivesSpaceSession.new
        session = options[:session]

        response = session.get(options[:path], page: options[:page], page_size: options[:page_size], resolve: ['linked_agents','subjects'])

        puts "Requesting page #{options[:page]} (#{Time.now.to_s})"

        if response.code.to_i == 200
          response = JSON.parse(response.body)
          records = response['results']
          records.each do |r|

            message = "#{r['uri']} - publish = #{r['publish']}, finding_aid_status = #{r['finding_aid_status'] || '[blank]'}"
            Rails.logger.info message; puts message

            if r['publish'] && r['finding_aid_status'] == "completed"
              @resources_updated += 1
              resource = Resource.create_or_update_from_data(r, options)
              resource.update_tree_from_api
            end
          end
        else
          raise response.body
        end

        message = "#{@resources_updated} resources updated so far."
        Rails.logger.info message; puts message

        options[:page] += 1
      end

    end

    create(import_type: 'full', resources_updated: @resources_updated)

    Rails.logger.info "AspaceImport.execute_full complete"

  end


  # Update records that have changed since last import, checking against Solr for changes
  # Changes to archival objects will trigger re-import of the parent resource
  def self.execute_delta(options={})

    log_info "AspaceImport.execute_delta called"
    import_type = options[:import_type] || 'delta'
    last_datetime = AspaceImport.last_import_date

    # format last_datetime to look like this: 2014-05-21T15:20:37Z
    since = options[:since] || last_datetime

    log_info "Options passed to execute_delta: #{ options.inspect }"
    since = since.to_datetime.new_offset(0).strftime('%Y-%m-%dT%H:%M:%SZ')
    since.gsub!(/\:/,'\:')

    log_info "Finding records updated since #{ since }"

    @update_resource_trees = []

    @total_resources = Resource.count

    @total_updates = 0
    @resources_updated = 0
    @archival_objects_updated = 0
    @rows = 50

    digital_object_instance_refs = []

    ['resource', 'archival_object', 'digital_object'].each do |record_type|
      base_query = "(user_mtime:[#{since} TO NOW] OR system_mtime:[#{since} TO NOW]) AND publish:true AND primary_type:#{record_type}"

      case record_type
      when 'resource'
        puts "*** Resources ***"
        # model = Resource
        base_query += ' AND finding_aid_status:completed'
      when 'archival_object'
        puts "*** archival objects ***"
      when 'digital_object'
        puts "*** digital objects ***"
      end


      update_digital_object_instance_refs = Proc.new do |response_data|
        data = JSON.parse(response_data['json'])
        data['linked_instances'].each do |i|
          digital_object_instance_refs << i['ref']
        end

        digital_object_instance_refs.uniq!
      end


      get_updated_records = Proc.new do |start|
        query =  base_query.clone
        log_info "#{query}"

        start ||= 0
        response = AspaceImport.execute_query(query, rows: @rows, start: start)
        num_found = response['response']['numFound']
        @total_updates += num_found
        response['response']['docs'].each do |d|
          print '.'
          case record_type
          when 'resource'
            @update_resource_trees << d['id']
          when 'archival_object'
            @update_resource_trees << d['resource']
            @archival_objects_updated += 1
          when 'digital_object'
            # resource_uris = AspaceImport.get_digital_object_linked_resources(d)
            update_digital_object_instance_refs.call(d)
          end
        end

        @update_resource_trees.uniq!

        # throttle requests
        sleep(1)

        # if number of resources to be updated is more than 80% of the total resources,
        # then we might as well stop querying the ArchivesSpace Solr for updates and just do a full import
        if @update_resource_trees.length > (@total_resources * 0.8)
          puts
          log_info "AspaceImport.execute_delta aborted in lieu of full index due to number of updates"
          self.execute_full(options)
          return nil
        else
          if (start + @rows) < num_found
            get_updated_records.call(start + @rows)
          end
        end
      end


      get_updated_records.call(0)

      get_resources_for_digital_objects = Proc.new do

        batch = []

        base_query = "(user_mtime:[#{since} TO NOW] OR system_mtime:[#{since} TO NOW]) AND publish:true"

        digital_object_instance_refs.each_index do |i|
          batch << digital_object_instance_refs[i]

          if (i > 0 && i % 10 == 0) || (i == digital_object_instance_refs.length - 1)
            query = base_query.clone
            query += ' AND id:("'
            query += batch.join('","')
            query += '")'

            response = AspaceImport.execute_query(query)
            response['response']['docs'].each do |d|
              if d['resource']
                @update_resource_trees << d['resource']
                @archival_objects_updated += 1
              end
            end
            batch = []
          end
        end
        @update_resource_trees.uniq!
      end

      get_resources_for_digital_objects.call

      puts
    end


    @update_resource_trees.uniq!
    @update_resource_trees.delete_if { |x| x.blank? }

    @resources_updated += @update_resource_trees.length

    log_info "Total Resources to be updated: #{@resources_updated}"
    log_info "Resources to be updated: #{@update_resource_trees.join(', ')}"

    @update_resource_trees.each do |uri|
      resource_data = Resource.get_data_from_api(uri, options)
      begin
        log_info "Updating resource tree for #{uri}"
        if resource_data[:finding_aid_status].match(/[Cc]ompleted/) && resource_data[:publish]
          resource = Resource.create_or_update_from_data(resource_data, options)
          resource.reload
          resource.update_tree_from_api(options)
        else
          log_info "*** Resource #{uri} is not published/completed ***"
          @resources_updated -= 1
        end
      rescue Exception => e
        log_info "*** IMPORT ERROR ***"
        log_info "Resource tree update FAILED for #{uri}"
        log_info e
        log_info "***"
      end
    end

    if @total_updates > 0
      create(import_type: import_type,
        resources_updated: @resources_updated,
        archival_objects_updated: @archival_objects_updated)
    end

    log_info "AspaceImport.execute_delta complete"

  end


  def self.execute_hourly(num_hours=1)
    log_info "AspaceImport.execute_hourly called"
    num_hours ||= 1
    options = {
      since: num_hours.to_i.hours.ago,
      import_type: 'hourly'
    }
    self.execute_delta(options)
  end


  def self.execute_daily
    log_info "AspaceImport.execute_daily called"
    options = {
      since: 24.hours.ago,
      import_type: 'daily'
    }
    self.execute_delta(options)
  end


  # This method will not create a record in aspace_import table if called directly
  def self.execute_by_type(record_type,options={})
    page = options[:page] || 1
    last_page = nil
    session = options[:session] || ArchivesSpaceSession.new
    case record_type
    when 'resource'
      model = Resource
      page_size = 10
      path_segment = 'resources'
    when 'archival_object'
      model = ArchivalObject
      page_size = 30
      path_segment = 'archival_objects'
    end

    puts "Importing #{model.to_s.underscore.pluralize}..."

    Repository.find_each do |repo|

      path = "/repositories/#{repo.id}/#{path_segment}"

      # make initial request to get total pages:
      response = session.get(path, page: page, page_size: page_size)
      if response.code.to_i == 200
        response = JSON.parse(response.body)
        last_page ||= response['last_page']
      end

      options = {
        page: page,
        page_size: page_size,
        path: path,
        model: model,
        session: session
      }
      while options[:page] <= last_page
        get_page_of_records(options)
        options[:page] += 1
      end

      if record_type == 'archival_object'
        ArchivalObject.update_has_children
      end
    end
  end


  def self.get_page_of_records(options)
    session = options[:session] || ArchivesSpaceSession.new
    model = options[:model]

    response = session.get(options[:path], page: options[:page], page_size: options[:page_size], resolve: ['linked_agents','subjects'])

    puts "Requesting page #{options[:page]} (#{Time.now.to_s})"

    if response.code.to_i == 200
      response = JSON.parse(response.body)
      records = response['results']
      records.each do |r|
        if r['publish'] && !(model == Resource && r['finding_aid_status'] != "completed")
          model.create_or_update_from_data(r, options)
        end
      end
    else
      raise response.body
    end
  end


  # Delete resources not found in ArchivesSpace Solr
  def self.purge_deleted

    Rails.logger.info "AspaceImport.purge_deleted called"

    # resources
    puts "Purging records that have been deleted in ArchivesSpace (or with finding aid status other than 'completed')..."

    query_params = { 'fq' => ["publish:true", "finding_aid_status:(Completed OR completed)"] }

    @resources_deleted = 0

    @resource_count = Resource.count
    @batch_size = 100

    i = 0;
    start_id = 0

    while i < @resource_count

      batch = Resource.where("id > #{ start_id }").order("id ASC").limit(@batch_size).pluck(:id, :uri)

      # Resource.find_in_batches(batch_size: batch_size) do |batch|
      expect_count = (batch.length == @batch_size) ? @batch_size : batch.length
      query = 'id:('
      batch.each do |fields|
        id, uri = fields
        query += escape_uri(uri)
        query += (uri != batch.last) ? ' ' : ''
        i += 1
        if i % @batch_size == 0
          start_id = id
        end
      end
      query << ')'

      response = execute_query(query,query_params)

      if response['response']['numFound'] == 0
        puts query
      end

      if response['response']['numFound'] < expect_count
        num_deleted = expect_count - response['response']['numFound']
        batch.each do |fields|
          id, uri = fields
          if !solr_doc_exists?(uri,query_params)
            Rails.logger.info "#{uri} no longer exists - deleting..."
            # DELETE IT!
            r = Resource.find_by_uri(uri)
            r.destroy
            @resources_deleted += 1
            num_deleted -= 1
            if num_deleted == 0
              break
            end
          end
        end
      else
        print '.'
        sleep(1)
      end
    end


    if @resources_deleted > 0
      create(import_type: 'purge_deleted', resources_updated: @resources_deleted)
    end
    ArchivalObject.delete_orphans

    Rails.logger.info "AspaceImport.purge_deleted complete"

  end


  def self.execute_query(query, params={})
    solr_url = "http://#{ENV['archivesspace_host']}:#{ENV['archivesspace_solr_port']}#{ENV['archivesspace_solr_path']}"
    @solr = RSolr.connect :url => solr_url
    @solr_params = {:q => query }
    @solr_params.merge! params
    @response = @solr.get 'select', :params => @solr_params
  end


  def self.solr_doc_exists?(uri,params)
    query = "id:#{escape_uri(uri)}"
    response = execute_query(query,params)
    return (response['response']['numFound'] == 0) ? false : true
  end


  def self.escape_uri(uri)
    uri.gsub(/\//,'\/')
  end


  def self.last_import_date
    last = self.order('created_at DESC').limit(1).first
    if last
      last_date = last.created_at
    else
      i = self.generate_initial
      last_date = i.created_at
    end
    last_date
  end


  def self.generate_initial
    if self.count == 0
      first_resource = Resource.order('created_at ASC').limit(1).first
      first_archival_object = ArchivalObject.order('created_at ASC').limit(1).first
      datetime = first_resource.created_at < first_archival_object.created_at ?
        first_resource.created_at : first_archival_object.created_at
    end
    i = self.create
    i.update_attributes(created_at: datetime, updated_at: datetime)
    i.reload
  end


  def self.test_solr_connection
    query = '*:*'
    puts execute_query(query, rows: 1).inspect
  end


  def self.test_digital_object_linked_resources(digital_object_uri)
    linked_resources = []
    @rows = 50
    query = "id:\"#{digital_object_uri}\""
    response = AspaceImport.execute_query(query)
    puts response.inspect
    response['response']['docs'].each do |d|
      linked_resources += get_digital_object_linked_resources(d)
    end
    linked_resources
  end


  # Get all resources associated with a digital object's linked instances, using data from its Solr record
  # Returns an array of resource URIs
  def self.get_digital_object_linked_resources(response_data)
    linked_resources = []
    data = JSON.parse(response_data['json'])
    data['linked_instances'].each do |i|
      record_uri = i['ref']
      if record_uri.match(/archival_objects/)
        session = ArchivesSpaceApiUtility::ArchivesSpaceSession.new
        response = session.get(record_uri)
        data = JSON.parse(response.body)

        if data
          resource_uri = data['resource'] ? data['resource']['ref'] : nil
          if resource_uri
            linked_resources << resource_uri
          end
        end

      elsif record_uri.match(/resources/)
        linked_resources << record_uri
      end
    end
    linked_resources
  end


  # Load custom methods if they exist
  begin
    include AspaceImportCustom
  rescue
  end


end
