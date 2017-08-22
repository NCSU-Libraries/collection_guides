module AspaceContentUtilities

  include GeneralUtilities
  include AspaceUtilities
  include EadUtilities
  include ParseDateString
  include ActionView::Helpers::TextHelper

  # API Response helper methods

  # Convert notes array from API response to a simplified hash for use in views
  # Params:
  # +notes+:: Array of ArchivesSpace note objects as a Ruby array of hashes
  # return format:
  # {
  #   <note type (string)> => [
  #     {:content => <string>, :label => <string if present>, :position => <int> },
  #     ...
  #   ],
  #   ...
  # }
  def parse_notes(notes)
    parsed_notes = {}
    notes = remove_unpublished(notes)
    notes.each_index do |i|
      n = notes[i]
      note = { content: '', position: i }
      note[:label] = n['label'] if n['label']
      case n['jsonmodel_type']
      when "note_singlepart"
        note[:content] << parse_text_note(n)
      when "note_multipart"
        n['subnotes'].each do |nn|
          if nn['title'] && (nn['title'] != 'Missing Title')
            note[:content] << "<div class=\"subelement-heading subnote-heading\">#{ nn['title'] }</div>"
          end
          case nn['jsonmodel_type']
          when 'note_text'
            note[:content] << parse_text_note(nn)
          when 'note_chronology'
            note[:content] << parse_chronlist_note(nn)
          when 'note_definedlist'
            note[:content] << parse_deflist_note(nn)
          when 'note_orderedlist'
            note[:content] << parse_ordered_list_note(nn)
          end
        end
      end
      note_type = n['type'] || n['jsonmodel_type']
      (parsed_notes[note_type.to_sym] ||= []) << note

    end
    parsed_notes
  end


  # Convert chronlist note to HTML
  # Params:
  # +note+:: ArchivesSpace note object as a Ruby hash
  def parse_chronlist_note(note)
    list_content = ''
    note['items'].each do |item|
      list_content += '<div class="chronitem row">'
      list_content += "<div class=\"date\">#{item['event_date']}</div>"
      list_content += '<div class="events">'
      item['events'].each do |e|
        list_content += "<div class=\"event\">#{e}</div>"
      end
      list_content += '</div></div>'
    end
    escape_ampersands(list_content)
    !list_content.empty? ? "<div class=\"chronlist\">#{convert_ead_elements(list_content)}</div>" : ''
  end


  # Convert ordered list note to HTML
  # Params:
  # +note+:: ArchivesSpace note object as a Ruby hash
  def parse_ordered_list_note(note)
    list = ''
    items = note['items']
    if !items.empty?
      if note['enumeration'] && !note['enumeration'].blank? && note['enumeration'] != 'null'
        list += "<ol type=\"#{list_type_to_ol_type(note['enumeration'])}\">"
      else
        list += '<ul>'
      end
      items.each { |item| list += "<li>#{item}</li>" }
      list += (note['enumeration']) ? '</ol>' : '</ul>'
    end
    escape_ampersands(list)
    convert_ead_elements(list)
  end


  # Convert text note to HTML
  # Params:
  # +note+:: ArchivesSpace note object as a Ruby hash
  def parse_text_note(note)
    output = ''
    if note['content'].kind_of? Array
      note['content'].each { |c| output << add_paragraphs(c) }
    else
      output << add_paragraphs(note['content'])
    end
    escape_ampersands(output)
    convert_ead_elements(output)
  end


  # Convert definition list note to HTML
  # Params:
  # +note+:: ArchivesSpace note object as a Ruby hash
  def parse_deflist_note(note)
    list = ''
    items = note['items']
    if !items.empty?
      list += '<dl>'
      items.each { |item| list << "<dt>#{item['label']}</dt><dd>#{item['value']}</dd>" }
      list += '</dl>'
    end
    escape_ampersands(list)
    convert_ead_elements(list)
  end


  # Extract abstract note as HTML
  # Params:
  # +parsed_notes+:: Return value from parse_notes()
  def abstract_from_notes(parsed_notes)
    abstract_values = []
    if parsed_notes[:abstract]
      parsed_notes[:abstract].each do |a|
        abstract_values << a[:content]
      end
    end
    abstract_values.empty? ? nil : abstract_values.join(' ')
  end


  # Adds paragraphs to text content divided by multiple line breaks
  # Returns modified string, leaving original unchanged
  # Params:
  # +content+:: string of text
  def add_paragraphs(content)
    s = content.clone
    s.strip!
    # don't do anything unless there are line breaks
    # check for blockquote and remove spaces between blockquote and p if present
    if s.match(/\<blockquote\>/)
      s.gsub!(/\<blockquote\>\s*\n*\<p\>/,"<blockquote><p>")
      s.gsub!(/\<\/p\>\s*\n*\<\/blockquote\>/,"</p></blockquote>")
    end

    # remove existing divs and paragraphs
    # except inside <blockquote>
    s.gsub!(/(?<!\<blockquote\>)\<((p)|(div))\>/,'')
    s.gsub!(/\<\/((p)|(div))\>(?!\<\/blockquote\>)/,'')

    # wrap content in paragraph
    s.prepend("<p>")
    s << "</p>"

    # replace double line breaks with close/start paragraph
    s.gsub!(/\n{2,}/,"</p><p>")

    # blockquotes are now wrapped in a p, which is wrong, so fix that
    s.gsub!(/\<p\>\<blockquote\>/,"<blockquote>")
    s.gsub!(/\<\/blockquote\>\<\/p\>/,"</blockquote>")
    s
  end


  # Destructive version of add_paragraphs()
  # Params:
  # +content+:: string of text
  def add_paragraphs!(content)
    content.replace(add_paragraphs(content))
  end


  # Generate a 'human-readable' statement of extent from extent objects included in API response
  # Params:
  # +extents+:: Array of ArchivesSpace extent objects as a Ruby array of hashes
  def generate_extent_statement(extents)
    all_extents = []

    number_string_to_numeric = lambda do |number_string|
      number_string.strip
      # remove commas
      number_string.gsub!(/\,/,'')
      # convert whole numbers to to non-decimal form
      number_string.gsub!(/\.0+$/,'')
      # remove trailing zeros from decimals and convert to float
      if number_string.match(/\./)
        number_string.gsub!(/0+$/,'')
        number = number_string.to_f
      # or convert to integer
      else
        number = number_string.to_i
      end
    end

    linear_feet_string = lambda do |extent|
      if extent['number'].match(/^[\d\.\,]+$/)
        number = number_string_to_numeric.call(extent['number'])
        return (number == 1) ? "1 linear foot" : "#{number.to_s} linear feet"
      else
        return "#{extent['number']} linear feet"
      end
    end

    cubic_feet_string = lambda do |extent|
      if extent['number'].match(/^[\d\.\,]+$/)
        number = number_string_to_numeric.call(extent['number'])
        return (number == 1) ? "1 cubic foot" : "#{number.to_s} cubic feet"
      else
        return "#{extent['number']} linear feet"
      end
    end

    concat_number_and_type = lambda do |extent|
      type = extent['extent_type'].gsub(/_/,' ').singularize
      if extent['number'].match(/^[\d\.\,]+$/)
        number = number_string_to_numeric.call(extent['number'])
        return pluralize(number, type)
      else
        return "#{extent['number']} #{type.pluralize}"
      end
    end

    extents.each do |e|
      extent_parts = {}
      if e['extent_type'].match(/[Ll]in(ear)?[\._\s]*[Ff]((ee)|(oo))?t\.?/)
        extent_parts[:primary] = linear_feet_string.call(e)
      elsif e['extent_type'].match(/[Cc]ubic[\._\s]*[Ff]((ee)|(oo))?t\.?/)
        extent_parts[:primary] = cubic_feet_string.call(e)
      else
        extent_parts[:primary] = concat_number_and_type.call(e)
      end

      if e['container_summary']
        summary = e['container_summary'].gsub(/\n+/,', ').strip
        extent_parts[:summary] = summary
      end

      extent_parts.delete_if { |k,v| v.blank? }

      if extent_parts[:primary] && extent_parts[:summary]
        all_extents << "#{extent_parts[:primary]} (#{extent_parts[:summary]})"
      elsif extent_parts[:primary]
        all_extents << extent_parts[:primary]
      else
        all_extents << extent_parts[:summary]
      end
    end

    all_extents.join('; ')
  end


  # Convert array of date objects to a hash keyed on label (date type)
  # (creation, issued, copyright, etc.)
  # Params:
  # +dates+:: Array of ArchivesSpace date objects as a Ruby array of hashes
  def sort_dates_by_label(dates)
    sorted = {}
    dates.each do |d|
      (sorted[d['label']] ||= []) << d
    end
    sorted
  end


  # Generate a 'human-readable' date statement from dates included in API response for a single record
  # Params:
  # +dates+:: Array of ArchivesSpace date objects as a Ruby array of hashes
  def generate_date_statement(dates)

    string_from_date = lambda do |date|
      if !date['expression'].blank?
        string = date['expression']
        string.gsub!(/\s+\-\s+/,'-')
      elsif date['date_type'] == 'single'
        string = date['begin']
      else
        string = "#{date['begin'] || ''}-#{date['end'] || ''}"
      end
      return string
    end

    sorted_dates = sort_dates_by_label(dates)
    creation_dates = sorted_dates['creation']
    inclusive_dates = nil
    bulk_dates = nil
    if creation_dates
      creation_dates.each do |d|
        case d['date_type']
        when 'inclusive','single','range'
          (inclusive_dates ||= []) << string_from_date.call(d)
        when 'bulk'
          (bulk_dates ||= []) << string_from_date.call(d)
        end
      end
    end

    date_statement = ''

    if inclusive_dates
      inclusive_dates_part = inclusive_dates.join(', ')
    end

    if bulk_dates
      bulk_dates_part = bulk_dates.join(', ')
      if !(bulk_dates_part.match(/[Bb]ulk/))
        bulk_dates_part.prepend('bulk ')
      end
    end

    if inclusive_dates && bulk_dates
      date_statement << "#{inclusive_dates_part} (#{bulk_dates_part})"
    elsif inclusive_dates
      date_statement << inclusive_dates_part
    elsif bulk_dates
      date_statement << bulk_dates_part
    end
    date_statement.empty? ? nil : date_statement
  end


  # Generate an array of years inclusive in all dates associated with a record
  # Params:
  # +dates+:: Array of ArchivesSpace date objects as a Ruby array of hashes
  def generate_inclusive_years(dates)

    current_year = Time.now.strftime('%Y').to_i

    # date values are ISO-8601 strings
    year_from_date_string = lambda do |date_string|
      return date_string ? date_string.split('-')[0].to_i : nil
    end
    years = []
    sorted_dates = sort_dates_by_label(dates)
    creation_dates = sorted_dates['creation']
    if creation_dates
      creation_dates.each do |date|
        if !date['expression'].blank? && !date['begin'] && !date['end']
          # parse expression
          parser = ParseDateString::Parser.new(date['expression'])
          date_values = parser.parse
          years += date_values[:index_dates]
        elsif date['date_type'] == 'single' && date['begin']
          years << year_from_date_string.call(date['begin'])

        elsif date['begin'] || date['end']
          # inclusive or range
          if date['begin'] && !date['end']
            range_start = year_from_date_string.call(date['begin'])
            range_end = current_year
            years += (range_start..range_end).to_a
          elsif date['end'] && !date['begin']
            # too ambiguous - only include end date
            years << year_from_date_string.call(date['end'])
          elsif date['begin'] && date['end']
            range_start = year_from_date_string.call(date['begin'])
            range_end = year_from_date_string.call(date['end'])
            years += (range_start..range_end).to_a
          end
        end
      end
    end

    years.uniq.sort
    # remove future years that may have been introduced from bad data
    years.delete_if { |x| x > current_year }

  end


end
