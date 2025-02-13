class AddOrUpdateDigitalObjectThumbnailData

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
    data = nil
    if sequence = get_first_sequence(manifest)
      if canvas = get_first_canvas(sequence)
        if image = get_first_image(canvas)
          data = {}
          data['thumbnailSrc'] = thumbnail_url(image)
          data['thumbnailLinkHref'] = thumbnail_link_function(manifest, image)
          data['imageCount'] = sequence['canvases'].length
          data['title'] = manifest['label']
        end
      end
    end
    
    data
  end

end