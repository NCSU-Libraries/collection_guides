class SearchIndex < ApplicationRecord

  require 'modules/general_utilities.rb'
  include GeneralUtilities

  @@batch_size = 50
  @@solr_url = "http://#{ENV['solr_host']}:#{ENV['solr_port']}#{ENV['solr_core_path']}"

  def self.check_solr
    @solr = RSolr.connect :url => @@solr_url
  end


  def self.total_in_index
    @solr = RSolr.connect :url => @@solr_url
    response = @solr.get 'select', :params => { :q => '*:*'}
    response['response']['numFound']
  end


  def self.wipe_index
    @solr = RSolr.connect :url => @@solr_url
    @solr.delete_by_query '*:*'
    @solr.commit
  end


  def self.update_record(record)
    @solr = RSolr.connect :url => @@solr_url
    doc = record.solr_doc_data
    @solr.add doc
    @solr.commit
  end


  def self.delete_record(record)
    @solr = RSolr.connect :url => @@solr_url
    @solr.delete_by_query "uri:#{record.uri.gsub(/\//,'\/')}"
    @solr.commit
  end


  def self.delete_record_by_uri(uri)
    @solr = RSolr.connect :url => @@solr_url
    @solr.delete_by_query "uri:#{uri.gsub(/\//,'\/')}"
    @solr.commit
  end


  def self.delete_by_query(query)
    @solr = RSolr.connect :url => @@solr_url
    @solr.delete_by_query(query)
    @solr.commit
  end


  def execute_full(options={})
    log_info "SearchIndex.execute_full called"
    # added conditional here to allow population of new index
    if options[:solr_url]
      @solr = RSolr.connect :url => options[:solr_url]
    else
      @solr = RSolr.connect :url => @@solr_url
    end
    if options[:clean]
      self.index_type = 'full_clean'
      SearchIndex.wipe_index
    else
      self.index_type = 'full'
    end
    @updated = 0
    update_resources
    update_archival_objects
    self.records_updated = @updated
    self.save
    log_info "SearchIndex.execute_full completed"
  end


  def execute_delta
    log_info "SearchIndex.execute_delta called"
    @solr = RSolr.connect :url => @@solr_url
    self.index_type = 'delta'
    @updated = 0
    last_index_time = SearchIndex.last ? SearchIndex.last.created_at.to_s(:db) : nil
    if last_index_time
      conditions = "updated_at > '#{last_index_time}'"
      update_resources(conditions)
      update_archival_objects(conditions)
      if @updated > 0
        @solr.commit
        self.records_updated = @updated
        self.save
      end
    else
      execute_full
    end
    log_info "SearchIndex.execute_delta completed"
  end


  def execute_hourly(options={})
    hours = options[:hours] ? hours.to_i : 1
    index_type = options[:index_type] || 'hourly'
    log_info "SearchIndex.execute_hourly called"
    @solr = RSolr.connect :url => @@solr_url
    self.index_type = index_type
    @updated = 0
    Resource.where('updated_at > ?', 1.hours.ago).find_in_batches(batch_size: @@batch_size) do |records|
      update_batch(records)
    end
    ArchivalObject.where('updated_at > ?', 1.hours.ago).find_in_batches(batch_size: @@batch_size) do |records|
      update_batch(records)
    end
    if @updated > 0
      @solr.commit
      self.records_updated = @updated
      self.save
    end
    puts
    log_info "SearchIndex.execute_hourly completed"
  end


  def execute_daily
    log_info "SearchIndex.execute_daily called (calls execute_hourly)"
    self.execute_hourly(hours: 24, index_type: 'daily')
    log_info "SearchIndex.execute_daily completed"
  end


  # actually 1 week plus 12 hours just in case
  def execute_weekly
    log_info "SearchIndex.execute_daily called (calls execute_hourly)"
    self.execute_hourly(hours: 180, index_type: 'weekly')
    log_info "SearchIndex.execute_daily completed"
  end


  def update_resources(conditions=nil)
    puts "Indexing resources..."
    Resource.where(conditions).find_in_batches(batch_size: @@batch_size) do |records|
      update_batch(records)
    end
    puts
  end


  def update_archival_objects(conditions=nil)
    puts "Indexing archival objects..."
    ArchivalObject.where(conditions).find_in_batches(batch_size: @@batch_size) do |records|
      update_batch(records)
    end
    puts
  end


  # Load custom methods if they exist
  begin
    include SearchIndexCustom
  rescue
  end


  private

  def update_batch(records)
    batch = []
    records.each { |r| batch << r.solr_doc_data }

    if @solr.add batch
      @updated += batch.length
      print '.'
    end
    @solr.commit
  end

end
