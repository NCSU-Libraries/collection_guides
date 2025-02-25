module DigitalObjectsHelper

  include ApplicationHelper
  include ActionView::Helpers::UrlHelper


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
        link = link_to(label, url, class: 'external')
        output = "<div id=\"#{id}\" class=\"#{link_class}\">#{link}</div>".html_safe
      end
    # end

    output
  end


  def digital_object_link_multi(digital_objects, label=nil)
    output = ''
    label ||= 'Digital content'

    digital_objects.each do |d|
      do_link = digital_object_link_single(d)

      if do_link
        output << digital_object_link_single(d)
      end
    end

    return (output.length > 0) ? output.html_safe : nil
  end


  def thumbnail_enabled_for_digital_object(digital_object)
    digital_object[:image_data] ? true : nil
  end


  # NCSU custom
  # override this in digital_objects_helper_custom.rb
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



  def thumbnail_visibility_toggle_output(presenter, tab)
    response = ''
    if presenter.digital_objects || presenter.has_descendant_digital_objects
      classes = ['thumbnail-visibility-toggle']
      if tab != 'contents'
        classes << 'hidden'
      end
      response += "<div class=\"#{classes.join(' ')}\"></div>"
    end
    response.html_safe
  end


  def thumbnail_viewer_output(presenter)
    # render thumbnails if enabled

    if presenter.digital_objects
      manifest_urls = []
      templates = []
      output = ''
      viewer_id = 'thumbnail-viewer' + presenter.id.to_s

      presenter.digital_objects.each do |d|
        if d['image_data']
          template = '<template class="image-data">'
          template += JSON.generate(d['image_data'])
          template += '</template>'
          templates << template
        end
      end

      if !templates.empty?
        output += "<div id=\"#{ viewer_id }\" class=\"thumbnail-viewer\"\">"
        output += templates.join("\n")
        output += '</div>'
      end
    end

    output
  end


  def archival_object_digital_object_link(presenter)
    output = ''
    if presenter.digital_objects
      if presenter.digital_objects.length == 1
        do_link = digital_object_link_single(presenter.digital_objects.first)
      elsif presenter.digital_objects.length > 1
        do_link = digital_object_link_multi(presenter.digital_objects)
      end
      if do_link
        output << do_link
      end
    end
    output.html_safe
  end


  def resource_digital_object_link
    output = ''
    standard_label = resource_digital_content_text
    if @presenter
      if @presenter.digital_objects
        if @presenter.digital_objects.length == 1
          output << digital_object_link_single(@presenter.digital_objects.first, standard_label)
        elsif @presenter.digital_objects.length > 1
          output << digital_object_link_multi(@presenter.digital_objects, standard_label)
        end
      elsif @presenter.has_descendant_digital_objects
        # output << link_to(standard_label, sal_collection_url(@presenter.collection_id), class: 'external')
        if @presenter.alt_digital_object_url
          output << link_to(standard_label, @presenter.alt_digital_object_url, class: 'external', target: '_blank')
        else
          output << standard_label
        end
      end
    end
    output.html_safe
  end


  def resource_digital_content_text
    "This collection contains digital content that is available online."
  end


  def resource_digital_object_output
    output = ''
    output << '<div class="resource-digital-object-info">'
    output << "<div class=\"digital-object-link\">#{ resource_digital_object_link()  }</div>"
    output << '</div>'
  end


  def resource_overview_digital_object_output
    output = ''
    output << '<div class="resource-overview-digital-object-info">'
    output << "<div class=\"digital-object-link\">#{ resource_digital_content_text }</div>"
    output << '</div>'
  end

end
