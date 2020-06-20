module DigitalObjectsHelperCustom

  def get_digital_object_url(digital_object)
    url = nil
    if digital_object[:files]
      digital_object[:files].each do |file|
        if file[:file_uri] =~ /d\.lib\.ncsu\.edu/
          url = file[:file_uri]
          if !(url.match(/^http/))
            url = 'https://' + url
          end
          break
        end
      end
    end
    url
  end


  def digital_object_link_single(digital_object, label=nil)
    output = ''

    # if (!thumbnail_enabled_for_digital_object(digital_object))
      if !digital_object[:digital_object_volumes].blank?

        # filesystem_browse_link = Proc.new do |url|
        #   label = "View contents"
        #   link_to(label, url, class: 'filesystem-browse-link')
        # end

        filesystem_browse_link = lambda do |volume_id|
          return "<span class=\"link filesystem-browse-link\" data-volume-id=\"#{ volume_id }\">View contents</span>"
        end

        if digital_object[:digital_object_volumes].length > 1
          volume_links = []
          digital_object[:digital_object_volumes].each do |v|
            volume_id = v[:volume_id]
            volume_links << filesystem_browse_link.call(volume_id)
          end
          output = volume_links.join("<br>\n")
        else
          volume_id = digital_object[:digital_object_volumes].first[:volume_id]
          output = filesystem_browse_link.call(volume_id)
        end

      elsif digital_object[:files]
        file = digital_object[:files].first
        url = file[:file_uri]
        if !(url.match(/^http/))
          url = 'http://' + url
        end
        label ||= 'Digital content'
        link_class = thumbnail_enabled_for_digital_object(digital_object) ?
            'external hidden' : 'external'
        id = "digital-object-link-#{ digital_object[:id] }"
        # output = link_to(label, url, class: link_class, id: id)
        link = link_to(label, url, class: 'external')
        output = "<div id=\"#{id}\" class=\"#{link_class}\">#{link}</div>".html_safe
      end
    # end

    output
  end


  def iiif_manifest_url(digital_object)
    url = get_digital_object_url(digital_object)
    if url && (url =~ /d\.lib\.ncsu\.edu\/collections\/catalog\//)
      url.gsub!(/^http:/,'https:')
      url.gsub!(/#?\?.*$/,'')
      url + '/manifest'
    else
      nil
    end
  end

end
