class AspaceImport < ApplicationRecord

  require 'modules/general_utilities.rb'
  include GeneralUtilities

  serialize :resource_list



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

      response = execute_solr_query(query,query_params)

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


  # def self.execute_solr_query(query, params={})
  #   solr_url = "#{ENV['archivesspace_https'] ? 'https' : 'http'}://#{ENV['archivesspace_solr_host']}#{ENV['archivesspace_solr_core_path']}"
  #   @solr = RSolr.connect :url => solr_url
  #   @solr_params = {:q => query }
  #   @solr_params.merge! params
  #   @response = @solr.get 'select', :params => @solr_params
  # end


  # def self.solr_doc_exists?(uri,params)
  #   query = "id:#{escape_uri(uri)}"
  #   response = execute_solr_query(query,params)
  #   return (response['response']['numFound'] == 0) ? false : true
  # end


  # def self.escape_uri(uri)
  #   uri.gsub(/\//,'\/')
  # end


  def self.last_import_date
    last = self.order('created_at DESC').limit(1).first
    last ? last.created_at : nil
  end


  # Load custom methods if they exist
  begin
    include AspaceImportCustom
  rescue
  end


end
