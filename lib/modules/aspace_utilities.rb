module AspaceUtilities

  def self.included receiver
    receiver.extend self
  end

  # Simple utility allow ASpace response data to be passed to methods as either
  # JSON (directly from API response) or Hash (when included as a linked record
  # in another response which has already been parsed)
  # Both formats (JSON and Hash) are returned, and the host method
  # must determine which to use for specific purposes
  # Params:
  # +data+:: API response, either as JSON or parsed as a Ruby hash
  def prepare_data(data)
    case data
    when Hash
      hash = ActiveSupport::HashWithIndifferentAccess.new(data)
      prepared_data = { :hash => hash, :json => JSON.generate(data) }
    when String
      hash = ActiveSupport::HashWithIndifferentAccess.new(JSON.parse(data))
      prepared_data = { :json => data, :hash =>  hash }
    end
    prepared_data
  end


  # remove all objects from arrays (and nested arrays) for which 'publish' is false
  # Params:
  # +array+:: Array of ArchivesSpace objects (of any class) as a Ruby hash
  def remove_unpublished(array)
    return_array = []

    array.each do |x|

      case x
      when Hash
        if x['publish']
          return_array << x
        else
          puts "removing unpublished: #{ x }"
        end
      when Array
        remove_unpublished(x)
      end
    end

    return_array
  end


  def archivesspace_solr_url
    url = ENV['archivesspace_https'] ? 'https://' : 'http://'
    if ENV['archivesspace_solr_host']
      url += ENV['archivesspace_solr_host']
    elsif ENV['archivesspace_host']
      url += ENV['archivesspace_host']
    else
      url += "localhost"
    end
    if ENV['archivesspace_solr_port']
      url += ":#{ENV['archivesspace_solr_port']}"
    end
    url += ENV['archivesspace_solr_core_path']
    url
  end


  def archivesspace_backend_url
    url = ENV['archivesspace_https'] ? 'https://' : 'http://'
    if ENV['archivesspace_backend_host']
      url += ENV['archivesspace_backend_host']
    elsif ENV['archivesspace_host']
      url += ENV['archivesspace_host']
    else
      url += "localhost"
    end
    if ENV['archivesspace_backend_port']
      url += ":#{ENV['archivesspace_backend_port']}"
    end
    url
  end

end
