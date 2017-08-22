module SearchHelper

  include ApplicationHelper

  def render_group(group, options={})
    output = ''
    docs = group['doclist']['docs']
    resource_data = {
      title: docs.first['resource_title'],
      uri: docs.first['resource_uri'],
      id: docs.first['resource_id'],
      date_statement: docs.first['resource_date_statement'],
      extent_statement: docs.first['resource_extent_statement'],
      collection_id: docs.first['resource_collection_id'],
      abstract: docs.first['resource_abstract'],
      primary_agent: docs.first['resource_primary_agent'],
      digital_content: docs.first['resource_digital_content'],
      eadid: docs.first['resource_eadid']
    }

    if resource_data[:eadid]
      resource_data[:path] = "#{root_path}#{resource_data[:eadid]}"
    else
      resource_data[:path] = "#{root_path}resources/#{resource_data[:id]}"
    end

    resource_data[:display_title] = resource_data[:date_statement] ?
      "#{resource_data[:title]}, #{resource_data[:date_statement]}" : resource_data[:title]
    output << "<div class=\"row search-result result-group#{ options[:class] ? (' ' + options[:class]) : '' }\">"

    if resource_data[:digital_content]
      output << '<div class="resource-digital-content right">'
      output << '<i class="fa fa-cubes"></i> <span>Digital content available</span>'
      output << '</div>'
    end

    if !resource_data[:primary_agent].blank?
      output << '<div class="creator">'
      output << resource_data[:primary_agent].join(', ')
      output << '</div>'
    end

    output << "<div class=\"resource-title\">#{link_to(resource_data[:display_title], resource_data[:path])}</div>"

    if !resource_data[:collection_id].blank? || !resource_data[:extent_statement].blank?
      output << '<div class="resource-details">'
        if !resource_data[:extent_statement].blank?
          output << "<span class=\"element-label\">Size:</span> <span class=\"extent-statement detail-data\">#{resource_data[:extent_statement]}</span> "
        end

        if !resource_data[:collection_id].blank?
          output << "<span class=\"element-label\">Resource Identifier:</span> <span class=\"collection-id detail-data\">#{resource_data[:collection_id]}</span> "
        end
      output << '</div>'
    end

    if resource_data[:abstract] && !resource_data[:abstract].empty?
      output << show_hide_block(resource_data[:abstract], class: 'abstract')
    end

    output << component_matches(group,resource_data)

    # output << show_test_data(group, resource_data[:uri].gsub(/\//,'-'))

    output << '</div>'
    output.html_safe
  end


  # For resource-specific results view (all docs are components of resource)
  def render_resource_results(docs, resource)
    output = ''
    docs.each do |d|
      output << '<div class="row search-result">'
      link_label = ''

      if !d['component_ancestors_title'].blank?
        link_label << "#{d['component_ancestors_title'].join(' &raquo; ')} &raquo; "
      end

      link_label << "<span class=\"component-title\">#{d['title']}</span>"

      output << '<div class="columns small-9">'
      output << link_to(link_label.html_safe,"#{root_path}resources/#{resource.id}/contents?archival_object_id=#{d['record_id']}",
        class: 'archival-object-link')
      if d['date_statement']
        output << " <span class=\"date\">#{d['date_statement']}</span>"
      end
      output << '</div>'

      if d['containers']
        output << '<div class="columns small-3">'
        output << "<span class=\"containers\">#{ d['containers'].join('; ') }</span>"
        output << '</div>'
      end

      output << '</div>'
    end
    output.html_safe
  end


  def component_matches(group, resource_data)
    total = group['doclist']['numFound']
    docs = group['doclist']['docs']
    heading = "Found in:"

    # docs.delete_if { |x| x['record_type'] == 'resource' }
    docs.each_index do |i|
      if docs[i]['record_type'] == 'resource'
        docs.delete_at(i)
        total -= 1
        heading = "Also found in:"
      end
    end

    if !docs.empty?
      list = '<ul class="resource-component-results">'
      docs.each do |d|
        item = '<li class="row">'
        link_label = ''
        if !d['component_ancestors_title'].blank?
          link_label << "#{d['component_ancestors_title'].join(' &raquo; ')} &raquo; "
        end
        link_label << "<span class=\"component-title\">#{d['title']}</span>"

        item_col1 = '<span class="columns small-9">'

        item_col1 << "#{link_to(link_label.html_safe,"#{resource_data[:path]}/contents?archival_object_id=#{d['record_id']}")}"

        if d['date_statement']
          item_col1 << " <span class=\"date\">#{d['date_statement']}</span>"
        end
        item_col1 << '</span>'
        item << item_col1

        if d['containers']
          item << '<span class="columns small-3">'
          item << "<span class=\"containers\">#{ d['containers'].join('; ') }</span>"
          item << '</span>'
        end

        item << "</li>"

        list << item
      end

      output = '<div class="component-results">'
      output << "<div class=\"list-heading\">#{heading}</div>"
      output << list

      if total > docs.length
        remaining = total - docs.length
        resource_results_options = @base_href_options.clone
        resource_results_options[:resource_id] = resource_data[:id]
        resource_results_path = searches_path(resource_results_options)
        output << "<div class=\"more-results\">#{link_to("+ #{remaining} more",resource_results_path)}</div>"
      end

      output << '</div>'
      output.html_safe
    else
      ''
    end
  end


  # def set_pagination_vars(params)
  #   @per_page = params[:per_page] ? params[:per_page].to_i : 20

  #   if params[:resource_id]
  #     @total_components = @response['response']['numFound']
  #     @pages = (@total_components/@per_page).ceil
  #   else
  #     @total_collections = @response['facet_counts']['facet_fields']['resource_uri'].length / 2
  #     @pages = (@total_collections/@per_page).ceil
  #   end

  #   @page = params[:page] ? params[:page].to_i : 1

  #   if @page <= 6
  #     @page_list_start = 1
  #   elsif (@page > (@pages - 9)) && ((@pages - 9) > 10)
  #     @page_list_start = @pages - 9
  #   else
  #     @page_list_start = @page - 5
  #   end

  #   if (@pages < 10) || ((@page + 4) > @pages)
  #     @page_list_end = @pages
  #   else
  #     @page_list_end = @page_list_start + 9
  #   end
  # end


  def search_pagination
    if @pages > 1
      output = '<div class="row">'
      output << '<ul class="pagination">'

      if @page_list_start == 1
        output << "<li class=\"arrow unavailable\">&laquo;</li>"
      else
        output << "<li class=\"arrow\">#{link_to('&laquo;'.html_safe, @base_href)}</li>"
      end

      (@page_list_start..@page_list_end).each do |n|
        href_options = @base_href_options.clone
        href_options[:page] = n
        href = searches_path(href_options)

        if n == @page
          output << "<li class=\"current\">"
        else
          output << "<li>"
        end

        output << link_to(n.to_s, href)
        output << "</li>"
      end

      last_href_options = @base_href_options.clone
      last_href_options[:page] = @pages
      last_href = searches_path(last_href_options)

      if @page_list_end == @pages
        output << "<li class=\"arrow unavailable\">&raquo;</li>"
      else
        output << "<li class=\"arrow\">#{link_to('&raquo;'.html_safe, last_href)}</li>"
      end

      output << '</ul>'
      output << '</div>'
      output.html_safe
    end
  end


  def resource_categories
    {
      'ua' => 'University Archives',
      'mss' => 'Manuscripts',
      'rb' => 'Rare Books'
    }
  end


  def filters_heading
    "Filter#{ @all_resources ? '' : ' results'}:"
  end


  def facet_options
    output = '<div id="search-facets-options">'
    output << "<h2 class=\"filter-heading\">#{ filters_heading }</h2>"
    ignore_facets = ['resource_uri']

    @facets.each do |k,v|
      if !ignore_facets.include?(k) && !v.empty?
        output << '<div class="facet">'
        case k
        when 'resource_digital_content'
          link = filter_link(k, true, label: t('digital_content_filter_label'))
          output << "<ul><li>" + link + "</li></ul>"

        when 'inclusive_years'
          output << '<h3>Dates</h3>'
          output << inclusive_years_facet_options

        else
          output << "<h3>#{facet_heading(k)}</h3>"
          output << facet_option_values(k, v)
        end
        output << '</div>'
      end
    end

    output << '</div>'
    output.html_safe
  end




  def facet_heading(facet)
    facet.gsub(/_/, ' ').split.map(&:capitalize).join(' ')
  end


  def facet_option_values(facet, values)
    content = ''
    content << '<ul>'
    values.each do |v,count|
      content << "<li>#{ filter_link(facet, v, multivalued: true) }</li>"
    end
    content << '</ul>'
    output = values.length > 5 ? "<div class=\"scrollable\">#{ content }</div>" : content
    output.html_safe
  end



  # Generate options for inclusive_years facet as date ranges
  # Params:
  # +increment+:: length of range (e.g. value of 10 will yield a list of decades)
  # +threshold+:: earliest year to list (earlier dates will be listed as "Before #{ threshold }")
  def inclusive_years_facet_options(increment=10, threshold=1800)
    output = ''
    if @facets['inclusive_years']
      range_values = []
      active_range_start = nil
      range_start_list = []
      current_year = Time.now.strftime('%Y').to_i

      @facets['inclusive_years'].each do |y, count|
        year = y.to_i
        if year <= current_year
          range_start = (year < threshold) ? threshold : (year - (year % increment))
          active_range_start ||= range_start

          if !range_start_list.include? range_start
            range_start_list << range_start
            if year < threshold
              range_values << { value: "#{year}-#{threshold - 1}", label: "before #{threshold}" }
              active_range_start = threshold - 1
            else
              range_end = range_start + (increment - 1)
              if range_end > current_year
                range_end = current_year
                range_values << { value: "#{range_start}-#{range_end}", label: "#{range_start}-present" }
              else
                range_values << { value: "#{range_start}-#{range_end}" }
              end
              active_range_start = range_start
            end
          end
        end
      end

      content = ''
      if !range_values.empty?
        content << '<ul class="date-range-options">'
        range_values.reverse.each do |r|
          content << "<li>#{ filter_link('inclusive_years',r[:value], label: r[:label], multivalued: true) }</li>"
        end
        content << '</ul>'
        output = (range_values.length > 6) ? "<div class=\"scrollable\">#{ content }</div>" : content
      end

    end
    output
  end






  def filter_link(facet,value,options={})
    output = ''
    label = options[:label] || value
    href_options = @base_href_options.clone

    filters = @filters.clone

    active_facet_value = nil

    if filters[facet]
      if (options[:multivalued] && filters[facet].include?(value)) ||
        (filters[facet] == value || value === true)
          active_facet_value = true
      end
    end

    # TODO - push selected to top of list, but not for dates

    if active_facet_value

      if filters[facet].kind_of? Array
        filters[facet].delete(value)
      else
        filters.delete(facet)
      end

      output << '<span class="active-facet">'
      output << label
      remove_label = '<i class="fa fa-times-circle"></i>'
      href_options[:filters] = filters
      href = searches_path(href_options)

      output << link_to(remove_label.html_safe, href, { class: 'remove-facet-link', title: 'Remove filter' } )
      output << '</span>'

    elsif filters[facet] && !options[:multivalued] && !active_facet_value
      # skip

    else
      if options[:multivalued]
        filters[facet] ||= []
        filters[facet] << value
      else
        filters[facet] = value
      end
      href_options[:filters] = filters
      href = searches_path(href_options)
      output << link_to(label, href, class: 'search-filter-link')
    end
    output.html_safe
  end


  def active_filters
    if !@filters.blank?

      output = '<div class="row" id="active-filters">'
      output << "<span class=\"label\">#{'Filter'.pluralize(@filters.length)}:</span> "
      @filters.each do |k,v|
        case k
        when 'resource_digital_content'
          output << filter_link(k, true, label: 'Has digitial content')
        when 'university_archives'
          output << filter_link(k,v, label: 'University Archives')
        when 'resource_category'
          output << filter_link(k, v, label: resource_categories[v])
        # when 'inclusive_years'
        #   v.each do |range|
        #     output << filter_link(k, range, multivalued: true)
        #   end
        else
          v.each do |value|
            output << filter_link(k, value, multivalued: true)
          end
        end
      end
      output << '</div>'
      output.html_safe
    end
  end


  def results_heading
    output = '<h1 class="row">'
    if !@q.blank?
      if @resource && @total_components
        resource_path = "#{root_path}resources/#{@resource.id}"
        output << "Found #{@total_components} matches for <span class=\"query-term\">#{@q}</span> in #{link_to(@resource.title, resource_path)}"
      else
        output << "Found matches for <span class=\"query-term\">#{@q}</span> in #{@total_collections} collections"
      end
    else
      if @subject
        output << "#{@total_collections} #{'collection'.pluralize(@total_collections)} related to <span class=\"query-term\">#{@subject.subject}</span>"
      elsif @agent
        output << "#{@total_collections} #{'collection'.pluralize(@total_collections)} related to <span class=\"query-term\">#{@agent.display_name}</span>"
      elsif @all_resources && @filters.blank?
        output << "Browse collections"
      elsif @filters
        output << "Showing #{@total_collections} collections"
      else
        output << "Showing all #{@total_collections} collections"
      end
    end
    output << '</h1>'
    output.html_safe
  end


  def simple_response
    response_data = { documents: [] }

    @response['grouped']['resource_uri']['groups'].each do |group|
      doc = group['doclist']['docs'].first
      title = doc["resource_title"]
      if doc["resource_date_statement"]
        title << ", #{doc["resource_date_statement"]}"
      end
      url = "http://#{request.host}#{root_path}#{doc["resource_eadid"]}"
      response_data[:documents] << { url: url, title: title }
    end
    response_data[:total] = @response['facet_counts']['facet_fields']['resource_uri'].length / 2
    response_data
  end





  # Load custom methods if they exist
  begin
    include SearchHelperCustom
  rescue
  end


end
