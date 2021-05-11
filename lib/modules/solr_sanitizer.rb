module SolrSanitizer

  # ILLEGAL_SOLR_CHARACTERS_REGEXP = /+|-|!|(|)|{|}|[|]|^||"|~|*|?|:|;|&&|||/


  def self.sanitize_query_string(value)
    disallow_characters_regex = /[\/\'\"\+\=\(\)\{\}\[\]\<\>\^\!\~\*\?\:\;(\&+)]/
    if value
      value.gsub!(disallow_characters_regex," ")
      value.gsub!(/\s+/," ")
      value.gsub!(/(\s\.)*/,".")
      value.gsub!(/\.+/,".")
      value.strip
    end
  end

  # returns a string
  def self.sanitize_integer(value)
    value.to_s.gsub(/[^\d]/,'')
  end

  # returns a string
  def self.sanitize_year(value)
    year = value.to_s.gsub(/[^\d]/,'')
    if year.length > 4
      year = year.byteslice(0,4)
    end
    year
  end


  def self.sanitize_numeric_range(value)
    # same as string regex but allows [ ] and *
    range_regex = /\[[\*\d]+ TO [\*\d]+\]/
    value =~ range_regex ? value : nil
  end

end
