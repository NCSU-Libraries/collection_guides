class AddOrUpdateDigitalObjectImageData

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
    if manifest = get_manifest
      data = get_thumbnail_data(manifest)
      puts data.inspect
      @digital_object.update!(image_data: data)
    end
  end

  def get_manifest
    if url = @digital_object.iiif_manifest_url
      if response = get_data_from_url(url, false)
        (response[:response].kind_of?(Net::HTTPSuccess) && response[:response].body) ? JSON.parse(response[:response].body) : nil
      else
        nil
      end
    else
      nil
    end
  end

  def get_first_sequence(manifest)
    manifest.dig('sequences', 0)
  end

  def get_first_canvas(sequence)
    sequence.dig('canvases', 0)
  end

  def get_first_image(canvas)
    canvas.dig('images', 0)
  end

  def get_thumbnail_data(manifest)
    id = manifest['@id']
    link_url = id.gsub(/\/manifest\/?(\.jso?n)?$/,'')
    data = nil

    if sequence = get_first_sequence(manifest)
      if canvas = get_first_canvas(sequence)
        if image = get_first_image(canvas)
          thumbnail_base_url = image['resource']['service']['@id'];
          data = {}
          data['thumbnailBaseUrl'] = thumbnail_base_url
          data['thumbnailLinkHref'] = link_url
          data['imageCount'] = sequence['canvases'].length
          data['title'] = manifest['label']
        end
      end
    end
    
    data
  end

end