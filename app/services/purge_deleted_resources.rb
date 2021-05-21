# This service has been placed in "Reporting mode"!


class PurgeDeletedResources

  include GeneralUtilities

  def self.call(options={})
    object = new(options={})
    object.call
  end

  def initialize(options={})
    @options = options
  end

  def call
    execute
  end


  private


  def execute

    @reporting_mode = nil

    log_info "PurgeDeletedResources called"
    log_info "Purging resources that have been deleted in ArchivesSpace (or with finding aid status other than 'completed')..."

    if @options[:delete_resources]
      log_info "Called with :delete_resources - @reporting_mode disabled. RESOURCES WILL BE DESTROYED!"
      @reporting_mode = false
    else
      log_info "@reporting_mode enabled - no records will actually be deleted. It's cool."
    end

    query_params = { 'fq' => ["publish:true", "finding_aid_status:(Completed OR completed)"] }
    @resources_deleted = 0
    @resource_count = Resource.count
    @batch_size = 100
    i = 0;
    start_id = 0


    # *** FOR REPORTING MODE ***
    @missing_resources = []

    while i < @resource_count

      batch = Resource.where("id > #{ start_id }").order("id ASC").limit(@batch_size).pluck(:id, :uri)
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

      response = ExecuteAspaceSolrQuery.call(query: query, params: query_params)

      if response['response']['numFound'] == 0
        puts query
      end

      if response['response']['numFound'] < expect_count
        num_deleted = expect_count - response['response']['numFound']
        batch.each do |fields|
          id, uri = fields
          if !solr_doc_exists?(uri,query_params)
            

            # *** REPORTING MODE - REMOVES THE CALL TO DELETE *** 
            if !@reporting_mode
              log_info "#{uri} no longer exists - deleting..."
              ## DELETE IT!
              r = Resource.find_by_uri(uri)
              r.destroy
            else
              log_info "Not found in ArchivesSpace index: #{uri}"
            end

            # *** REPORTING MODE ***
            @missing_resources << uri

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

    # *** REPORTING MODE - REMOVES THE CALL TO CREATE AspaceImport record *** 
    if !@reporting_mode
      if @resources_deleted > 0
        AspaceImport.create(import_type: 'purge_deleted', resources_updated: @resources_deleted)
      end
    end

    # *** REPORTING MODE - REMOVES THE CALL TO DELETE ORPHANED RECORDS ***
    if !@reporting_mode
      ArchivalObject.delete_orphans
    end

    log_info "AspaceImport.purge_deleted complete"
    log_info "Missing resources:"
    log_info @missing_resources.inspect
  end


  def solr_doc_exists?(uri,params)
    query = "id:#{escape_uri(uri)}"
    response = ExecuteAspaceSolrQuery.call(query: query, params: params)
    return (response['response']['numFound'] == 0) ? false : true
  end


  def escape_uri(uri)
    uri.gsub(/\//,'\/')
  end

end