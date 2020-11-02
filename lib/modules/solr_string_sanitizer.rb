  module SolrStringSanitizer
    # ILLEGAL_SOLR_CHARACTERS_REGEXP = /+|-|!|(|)|{|}|[|]|^||"|~|*|?|:|;|&&|||/
    DISALLOW_CHARACTERS_REGEXP = /[\/\'\"\+\=\(\)\{\}\[\]\^\!\~\*\?\:\;(\&+)]/

    def self.sanitize(string)
      if string
        string.gsub!(DISALLOW_CHARACTERS_REGEXP," ")
        string.gsub(/\s+/," ").strip
      end
    end
  end
