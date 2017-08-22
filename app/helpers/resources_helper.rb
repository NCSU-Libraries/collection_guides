module ResourcesHelper
  include ApplicationHelper
  include ArchivalObjectsHelper
  include DigitalObjectsHelper

  def resource_overview
    if @presenter
      overview = '<dl class="inline-dl resource-overview row">'

      if !@presenter.primary_agent.blank?
        overview << "<dt class=\"columns\">#{'Creator'.pluralize(@presenter.primary_agent.length)}</dt>"
        overview << "<dd#{rdfa_property_attribute(:origination)} class=\"columns\">#{@presenter.primary_agent.join('; ')}</dd>"
      end

      if !@presenter.extent_statement.blank?
        overview << '<dt class="columns">Size</dt>'
        overview << "<dd#{rdfa_property_attribute(:extent)} class=\"columns\">#{@presenter.extent_statement}</dd>"
      end

      if !@presenter.collection_id.blank?
        overview << '<dt class="columns">Call number</dt>'
        overview << "<dd property=\"dcterms:identifier\" class=\"columns\">#{@presenter.collection_id}</dd>"
      end

      overview << '</dl>'

      # if @presenter.has_digital_objects || @presenter.has_descendant_digital_objects
      #   overview << resource_digital_object_output()
      # end

    end
    overview.html_safe
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



  def resource_title
    title_html = ''
    title_html << "<span property=\"schema:name dcterms:title\">#{@resource.title}</span>"
    if !@presenter.date_statement.blank?
      title_html << " <small class=\"date\" property=\"schema:dateCreated dcterms:created\">#{ @presenter.date_statement }</small>"
    end
    title_html.html_safe
  end


  def resource_abstract
    if @presenter.abstract
      output = "<div class=\"abstract\"#{rdfa_property_attribute(:abstract)}>#{@presenter.abstract.html_safe}</div>"
      output.html_safe
    end
  end


  def resource_notes
    output = ''
    note_elements.map { |x| x.to_sym}.each do |e|
      if @presenter.notes[e]
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


  def render_tree
    if @resource.has_children
      if (@resource.total_components > 1000) && !@escaped_fragment
        render_skeleton_tree
      else
        tree_content = ''
        tree_content << render_series_nav
        tree_item = lambda do |record, level_num|
          p = record.presenter
          content = archival_object_html(record, layout: false)
          if record.has_children
            record.children.each { |c| content << tree_item.call(c, level_num + 1)}
          end
          output = archival_object_div(content, level_num: level_num, level_text: p.level, id: p.record.id)
          return output
        end

        @resource.children.each { |c| tree_content += tree_item.call(c, 1) }

        content_tag('div', tree_content.html_safe, class: 'resource-tree')
      end
    end
  end


  def render_skeleton_tree
    id_tree = JSON.parse(@resource.structure).deeper_symbolize_keys!
    tree_content = ''
    tree_content << render_series_nav
    tree_item = lambda do |branch, level_num|
      content = ''
      if branch[:children]
        branch[:children].each { |c| content << tree_item.call(c, level_num + 1)}
      end
      case branch[:node_type]
      when 'archival_object'
        output = archival_object_div(content, skeleton_tree: true, level_num: level_num, level_text: branch[:level], id: branch[:id])

      # TODO - is this even a use case?
      when 'digital_object'
        output = content_tag('div', content.html_safe, class: 'skeleton-tree-item tree-item tree-item-#{level_num.to_s}',
          id: "digital-object-#{branch[:id]}",
          data: { digital_object_id: branch[:id] })
      end

      return output
    end
    id_tree[:children].each { |c| tree_content += tree_item.call(c, 1) }
    content_tag('div', tree_content.html_safe, class: 'resource-tree skeleton-tree')
  end


  def render_series_nav
    if !@resource.series.empty?
      output = '<div class="arrangement series-nav element-content">'
      output << "<p>The collection is organized into #{ number_to_text(@resource.series.length) } principal series:</p>"
      output << '<ul>'
      @resource.series.order('position asc').each do |s|
        output << "<li>"
        output << "<a class=\"series-link\" data-series-id=\"#{ s.id }\" href=\"#archival-object-#{ s.id }\">#{ s.title }</a>"
        output << "</li>"
      end
      output << '</ul>'
      output << '</div>'
      output.html_safe
    else
      ''
    end
  end


  def archival_object_div(content, options={})
    css_classes = ['tree-item']
    id = nil
    data = {}
    options.each do |k,v|
      case k
      when :level_num
        css_classes << "tree-item-#{v}"
      when :level_text
        css_classes << "#{v}-level"
      when :id
        id = "archival-object-#{v}"
        data[:archival_object_id] = v
      end
    end
    if options[:skeleton_tree]
      css_classes << 'skeleton-tree-item'
    else
      css_classes << 'loaded'
    end
    content_tag('div', content.html_safe, class: css_classes.join(' '), id: id, data: data)
  end


  def names_and_subjects
    output = ''

    if @presenter.agents
      agents_output = '<div class="access-terms-group agents">'
      agents_output << '<div class="element-label">Names</div>'
      agents_output << '<ul>'
      @presenter.agents.each do |a|
        agents_output << "<li class=\"agent\">"
        agents_output << agent_search_link(a).html_safe
        if a[:relator_term]
          agents_output << " (#{a[:relator_term]})"
        end
        agents_output << "</li>"
      end
      agents_output << '</ul></div>'
      output << agents_output
    end

    if @presenter.subjects
      subjects_output = '<div class="access-terms-group subjects">'
      subjects_output << '<div class="element-label">Subjects</div>'
      subjects_output << '<ul>'
      @presenter.subjects.each do |s|
        subjects_output << "<li class=\"subject\">#{ subject_search_link(s).html_safe }</li>"
      end
      subjects_output << '</ul></div>'
      output << subjects_output
    end

    output.html_safe
  end


  # Load custom methods if they exist
  begin
    include ResourcesHelperCustom
  rescue
  end

end
