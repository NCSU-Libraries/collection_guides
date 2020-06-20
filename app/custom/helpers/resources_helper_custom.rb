module ResourcesHelperCustom

  def resource_overview
    if @presenter
      # overview = '<div class="grid-x row resource-overview">'

      overview = '<dl class="inline-dl">'

      if !@presenter.primary_agent.blank?
        overview << "<dt class=\"cell\">#{'Creator'.pluralize(@presenter.primary_agent.length)}</dt>"
        overview << "<dd#{rdfa_property_attribute(:origination)} class=\"cell\">#{@presenter.primary_agent.join('; ')}</dd>"
      end

      if !@presenter.extent_statement.blank?
        overview << '<dt class="cell">Size</dt>'
        overview << "<dd#{rdfa_property_attribute(:extent)} class=\"cell\">#{@presenter.extent_statement}</dd>"
      end

      # if @presenter.notes[:physloc]
      #   location = ''
      #   @presenter.notes[:physloc].each { |l| location << l[:content] }
      # else
      #   location = "For current information on the location of these materials, please consult the Special Collections Research Center Reference Staff."
      # end

      # overview << '<dt class="cell">Location</dt>'
      # overview << "<dd property=\"schema:provider arch:heldBy\" resource=\"http://www.lib.ncsu.edu/ld/onld/00000658\" class=\"cell\">#{location}</dd>"

      if !@presenter.collection_id.blank?
        overview << '<dt class="cell">Call number</dt>'
        overview << "<dd property=\"dcterms:identifier\" class=\"cell\">#{@presenter.collection_id}</dd>"
      end

      if @presenter.notes[:accessrestrict]
        access_note = ''
        @presenter.notes[:accessrestrict].each { |a| access_note << a[:content] }
        # @presenter.notes.delete(:accessrestrict)
        overview << '<dt class="cell">Access to materials</dt>'
        overview << "<dd#{ rdfa_property_attribute(:accessrestrict) } class=\"cell\">#{ access_note }</dd>"
      end

      overview << '</dl>'

      # if @presenter.has_digital_objects_with_files || @presenter.has_descendant_digital_objects_with_files
      #   overview << resource_overview_digital_object_output
      # end

      # overview << '</div>'

    end
    overview.html_safe
  end


  def resource_notes
    skip_notes = [:accessrestrict, :physloc]
    display_note_elements = note_elements.map { |x| x.to_sym }
    display_note_elements.delete_if { |x| skip_notes.include?(x) }

    output = ''

    display_note_elements.each do |e|

      if e == :prefercite
        output << "<h2 class=\"element-heading\">#{note_label(e)}</h2>"
        output << "<div class=\"element-content\"#{rdfa_property_attribute(e)}>#{standard_citation}</div>"
      elsif @presenter.notes[e]
        previous_label = ''
        @presenter.notes[e].each do |note|
          label = note_label(e, note)
          if label != previous_label
            output << "<h2 class=\"element-heading\">#{label}</h2>"
            previous_label = label
          end
          output << "<div class=\"element-content\"#{rdfa_property_attribute(e)}>#{note[:content]}</div>"
        end
      end
    end
    !output.empty? ? output.html_safe : ''
  end


  def access_info_output
    output = ''
    # elements = [:accessrestrict, :userestrict, :prefercite, ]

    add_notes_to_output = Proc.new do |element|
      if @presenter.notes[element]
        previous_label = ''
        @presenter.notes[element].each do |note|
          label = note_label(element, note)
          if label != previous_label
            output << "<h2 class=\"element-heading\">#{label}</h2>"
            previous_label = label
          end
          output << note[:content]
        end
      end
    end

    if @presenter.notes[:accessrestrict]
      output << "<h2 class=\"element-heading\">#{element_label(:accessrestrict)}</h2>"
      @presenter.notes[:accessrestrict].each { |n| output << n[:content] }
    else
      output << "<h2 class=\"element-heading\">#{element_label(:accessrestrict)}</h2>"
      output << standard_access_note
    end

    output << scrc_contact()

    output << "<h2 class=\"element-heading\">#{element_label(:prefercite)}</h2>"
    output << standard_citation

    if @presenter.notes[:userestrict]
      add_notes_to_output.call(:userestrict)
    else
      output << "<h2 class=\"element-heading\">#{element_label(:userestrict)}</h2>"
      output << standard_use_note
    end

    !output.empty? ? output.html_safe : ''

  end


  def sal_collection_url(collection_id)
    url = "http://d.lib.ncsu.edu/collections/catalog?f%5Beadid_facet%5D%5B%5D="
    url += collection_id.downcase.gsub(/\./,'_').gsub(/[^\w]/,'')
  end





  def standard_access_note
    "<p>This collection is open for research; access requires at least 48 hours advance notice.
    Because of the nature of certain archival formats, including digital and audio-visual materials,
    access to digital files may require additional advanced notice.<p>"
  end


  def standard_citation
    "<p>[Identification of item], #{ @presenter.title }, #{ @presenter.collection_id ? @presenter.collection_id + ', ' : '' }
    Special Collections Research Center, North Carolina State University Libraries, Raleigh, NC</p>"
  end


  def standard_use_note
    "<p>The nature of the NC State University Libraries' Special Collections means that copyright or other information
    about restrictions may be difficult or even impossible to determine despite reasonable efforts.
    The NC State University Libraries claims only physical ownership of most Special Collections materials.</p>
    <p>The materials from our collections are made available for use in research, teaching,
    and private study, pursuant to U.S. Copyright law. The user must assume full responsibility
    for any use of the materials, including but not limited to, infringement of copyright and publication
    rights of reproduced materials. Any materials used for academic research or otherwise should be fully
    credited with the source.<p>"
  end


  def scrc_contact
    output = '<div class="contact-information">'
    output << "<p>For more information contact us via mail, phone, or our #{ link_to('web form',
      'http://www.lib.ncsu.edu/scrc/request')}.</p>"
    output << '<p><span class="label">Mailing address:</span><br>Special Collections Research Center<br>
      Box 7111<br>Raleigh, NC, 27695-7111</p>'
    output << '<p><span class="label">Phone:</span> (919) 515-2273</p>'
    output << '</div>'
  end


end
