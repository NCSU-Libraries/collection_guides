module DigitalObjectsHelper

  include ApplicationHelper
  include ActionView::Helpers::UrlHelper

  # def digital_object_link_single(digital_object, label=nil)
  #   url = get_digital_object_url(digital_object)
  #   if url
  #     # label ||= digital_object[:title]
  #     label ||= 'Digital content'
  #     link_to(label, url, class: 'external')
  #   else
  #     nil
  #   end
  # end


  def digital_object_link_single(digital_object, label=nil)
    output = ''

    if (!thumbnail_enabled_for_digital_object(digital_object))
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
        output = link_to(label, url, class: 'external')
      end
    end
    output
  end


  def digital_object_link_multi(digital_objects, label=nil)
    output = ''
    label ||= 'Digital content'
    # output << label
    # output << '<br>'
    digital_objects.each do |d|
      if (!thumbnail_enabled_for_digital_object(d))
        do_link = digital_object_link_single(d)
        if do_link
          output << digital_object_link_single(d)
          if !(d == digital_objects.last)
            output += '<br>'
          end
        end
      end
    end
    return (output.length > 0) ? output.html_safe : nil
  end


  def get_digital_object_url(digital_object)
    if digital_object[:files]
      file = digital_object[:files].first
      url = file[:file_uri]
      if !(url.match(/^http/))
        url = 'http://' + url
      end
      url
    end
  end


  def thumbnail_enabled_for_digital_object(digital_object)
    thumbnail_enabled = nil
    if digital_object['show_thumbnails']
      url = get_digital_object_url(digital_object)
      if url
        thumbnail_enabled = true
      end
    end
    thumbnail_enabled
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
    standard_label = "Portions of this collection have been digitized and made available in the Libraries' Rare and Unique Digital Collections site."
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
          output << link_to(standard_label, @presenter.alt_digital_object_url, class: 'external')
        else
          output << standard_label
        end
      end
    end
    output.html_safe
  end


  def resource_digital_object_output
    output = ''
    output << '<div class="resource-digital-object-info">'
    output << "<div class=\"digital-object-link\">#{resource_digital_object_link()}</div>"
    # output << '<div class="digital-object-additional">Additional materials, including those not available online,
    #   may be available for viewing in the Special Collections reading room in D.H. Hill Library.
    #   Certain formats may require the creation of an access copy and will require additional advanced notice.</div>'
    output << '</div>'
  end


  def resource_overview_digital_object_output
    output = ''
    output << '<div class="resource-overview-digital-object-info">'
    output << "<div class=\"digital-object-link\">#{resource_digital_object_link()}</div>"
    output << '</div>'
  end


  # Load custom methods if they exist
  begin
    include DigitalObjectsHelperCustom
  rescue
  end

end
