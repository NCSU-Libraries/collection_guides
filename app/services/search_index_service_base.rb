class SearchIndexServiceBase

  include GeneralUtilities

  @@batch_size = 50
  @@solr_url = "http://#{ENV['solr_host']}:#{ENV['solr_port']}#{ENV['solr_core_path']}"

  def self.call(options={})
    object = new(options)
    object.call
  end

  def initialize(options)
    @options = options
    @solr = RSolr.connect :url => @@solr_url
  end

  def call
    execute
  end


  private


  def execute
  end


  def wipe_index
    @solr.delete_by_query '*:*'
    @solr.commit
  end


  def check_solr
    @solr = RSolr.connect :url => @@solr_url
  end


  def total_in_index
    response = @solr.get 'select', :params => { :q => '*:*'}
    response['response']['numFound']
  end


  def update_record(record)
    doc = record.solr_doc_data
    @solr.add doc
    @solr.commit
  end


  def delete_record(record)
    @solr.delete_by_query "uri:#{record.uri.gsub(/\//,'\/')}"
    @solr.commit
  end


  def update_in_batches(records)
    i = 0
    batch = []

    records.each do |r|
      batch << r.solr_doc_data
      i += 1
      if (i == @@batch_size) || (i == records.length)
        @solr.add batch
        @solr.commit
        print '.'
        batch = []
        i = 0
      end
    end
  end

end
