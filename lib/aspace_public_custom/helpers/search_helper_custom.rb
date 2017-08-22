module SearchHelperCustom

  SearchHelper.class_eval do

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
            output << "<span class=\"element-label\">Collection ID:</span> <span class=\"collection-id detail-data\">#{resource_data[:collection_id]}</span> "
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


    def facet_options

      output = '<div id="search-facets-options">'
      output << "<h2 class=\"filter-heading\">Filter#{ @all_resources ? '' : ' results'}:</h2>"
      ignore_facets = ['resource_uri']

      facet_headings = {
        'agents' => 'Names',
        'subjects' => 'Subjects',
        'ncsu_subjects' => 'NCSU Subjects'
      }

      @facets.each do |k,v|
        if !ignore_facets.include?(k) && !v.empty?
          output << '<div class="facet">'
          case k
          when 'resource_digital_content'
            link = filter_link(k, true, label: t('digital_content_filter_label'))
            output << "<ul><li>" + link + "</li></ul>"

          when 'resource_category'
            output << '<h3>Collection</h3>'
            output << '<ul>'

            resource_categories.each do |value,label|
              if v[value]
                link = filter_link(k, value, label: label)
                if link
                  output << "<li>#{ link }</li>"
                end
              end
            end
            output << '</ul>'

          when 'inclusive_years'
            output << '<h3>Dates</h3>'
            output << inclusive_years_facet_options

          else
            output << "<h3>#{facet_headings[k]}</h3>"
            output << facet_option_values(k, v)
          end
          output << '</div>'
        end
      end

      output << '</div>'
      output.html_safe
    end


  end






end
