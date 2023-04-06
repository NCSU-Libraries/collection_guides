class SearchService

  include GeneralUtilities

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



end
