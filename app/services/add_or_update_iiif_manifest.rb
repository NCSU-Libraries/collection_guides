class AddOrUpdateIiifManifest

  include HttpUtilities

  def initialize(digital_object, options = {})
    @digital_object = digital_object
    @options = options
  end

  def self.call(digital_object, options = {})
    new(digital_object, options).call
  end

  def call
    execute
  end

  private

  def execute
    # ...implementation code...
    manifest = get_manifest
    puts manifest.inspect
  end

  
  def get_manifest
    url = @digital_object.iiif_manifest_url

    if url
      response = get_data_from_url(url)
      if response[:response].kind_of?(Net::HTTPSuccess)
        response[:response].body
      else
        nil
      end
    else
      nil
    end
  end

end
