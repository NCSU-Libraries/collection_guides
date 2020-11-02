module SolrSanitizer

  # ILLEGAL_SOLR_CHARACTERS_REGEXP = /+|-|!|(|)|{|}|[|]|^||"|~|*|?|:|;|&&|||/


  def self.sanitize_query_string(value)
    disallow_characters_regex = /[\/\'\"\+\=\(\)\{\}\[\]\^\!\~\*\?\:\;(\&+)]/
    if value
      value.gsub!(disallow_characters_regex,"")
      value.gsub(/\s+/," ").strip
    end
  end

  # returns a string
  def self.sanitize_integer(value)
    value.to_s.gsub(/[^\d]/,'')
  end


  def self.sanitize_numeric_range(value)
    # same as string regex but allows [ ] and *
    range_regex = /\[[\*\d]+ TO [\*\d]+\]/
    value =~ range_regex ? value : nil
  end

end
