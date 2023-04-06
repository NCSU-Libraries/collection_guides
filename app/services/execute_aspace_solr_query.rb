class ExecuteAspaceSolrQuery

  include GeneralUtilities

  @@batch_size = 50
  @@solr_url =  "#{ENV['archivesspace_https'] ? 'https' : 'http'}://#{ENV['archivesspace_solr_host']}#{ENV['archivesspace_solr_core_path']}"

  def self.call(options={})
    object = new(options)
    object.call
  end

  def initialize(options)
    @options = options
    @query = @options[:query]
    @params = @options[:params] || {}
  end

  def call
    execute
  end


  private


  def execute
    if @query
      @solr = RSolr.connect :url => @@solr_url
      @solr_params = {:q => @query }
      @solr_params.merge! @params
      @solr.get 'select', :params => @solr_params
    else
      { error: "ExecuteAspaceSolrQuery: no query passed in options to call()" }
    end
  end


end
