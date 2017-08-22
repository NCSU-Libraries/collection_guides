module DateUtilities

  include GeneralUtilities

  # Convert standard ISO 8601 date string to full 'zulu' format used by Solr
  # Params:
  # +date_string+:: date string in basic ISO 8601 format with no timte, e.g. yyyy(-mm(-dd))
  def date_to_zulu(date_string)
    zulu_format = '%Y-%m-%dT12:%M:%SZ'
    date_string.to_s
    date_parts = date_string.split('-')
    date_parts[1] ||= '01'
    date_parts[2] ||= '01'
    date = Date.new(date_parts[0].to_i,date_parts[1].to_i,date_parts[2].to_i)
    date.strftime(zulu_format)
  end


  # Remove extraneous punctuation, etc. from a date string (not format-specific)
  # Params:
  # +string+:: A date string in any format
  def clean_date_string(string)
    if string
      remove_newlines(string)
      # remove the word "bulk"
      string.gsub!(/\s?[Bb]ulk\s?/,'')
      # remove leading commas, stops
      string.gsub!(/^[\.\,]/,'')
      # remove trailing commas, semicolons
      string.gsub!(/[\;\,]$/,'')
      # remove enclosing parentheses and curly braces (not square brackets, which might indicate supplied date)
      brackets = [[/^\{/,/\}$/,/^\{(.*\}.*)\}$/],[/^\(/,/\)$/,/^\((.*\).*)\)$/]]
      brackets.each do |b|
        if string.match(b[0]) && string.match(b[1]) && !string.match(b[2])
          string.gsub!(b[0],'')
          string.gsub!(b[1],'')
        end
      end
      string.strip!
    end
    string
  end


  # Converts an ISO 8601 date (single or range) with optional qualifier into a string for display
  # Params:
  # +iso_date+:: ISO 8601 formatted date
  # +qualifier+:: (optional) 'approximate' or 'questionable'
  def iso_8601_to_text(iso_date,qualifier=nil)
    iso_date.strip!
    string_formats = {
      :year => '%Y',
      :month => '%B %Y',
      :day => '%B %-d, %Y'
    }
    if iso_date.match('/')
      dates = iso_date.split('/')
      qualifiers = qualifier ? qualifier.split('/') : []

      start_date_args = { :date => (dates[0] || ''), :qualifier => (qualifiers[0] || nil) }
      end_date_args = { :date => (dates[1] || ''), :qualifier => (qualifiers[1] || nil) }

      start_date = iso_8601_to_text(start_date_args[:date],start_date_args[:qualifier])
      end_date = iso_8601_to_text(end_date_args[:date],end_date_args[:qualifier])

      # Note: using RDA conventions for open ranges ('not before' instead of 'after', etc.)
      if start_date && end_date
        return "#{start_date} - #{end_date}"
      elsif start_date && !end_date
        return "not before #{start_date}"
      elsif end_date && !start_date
        return "not after #{end_date}"
      end
    else
      qualify_date = lambda do |date|
        circa = (qualifier == 'approximate') ? 'circa ' : ''
        question = (qualifier == 'questionable') ? '?' : ''
        return circa + date + question
      end
      parse_string = iso_date.match(/^\d{4}$/) ? iso_date + '-01' : iso_date
      datetime = Chronic.parse(parse_string)
      if iso_date.match(/^\d{4}$/)
        date = datetime.strftime(string_formats[:year])
      elsif iso_date.match(/^\d{4}\-\d{2}$/)
        date = datetime.strftime(string_formats[:month])
      elsif iso_date.match(/^\d{4}\-\d{2}\-\d{2}$/)
        date = datetime.strftime(string_formats[:day])
      else
        date = nil
      end
      return date ? qualify_date.call(date) : nil
    end
  end

end
