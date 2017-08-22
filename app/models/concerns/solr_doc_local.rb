require 'active_support/concern'

module SolrDocLocal
  extend ActiveSupport::Concern
  # include ApiResponseData
  include ActionView::Helpers::SanitizeHelper

  included do

    def add_local_fields(doc,data=nil)
      data ||= parse_unit_data
      doc[:collection_id] = data[:collection_id]
      add_resource_category(doc)
      # if self.class == Resource
      #   add_university_archives_flag(doc,data)
      # end
    end


    def add_university_archives_flag(doc,data)
      match_regex = [/^[Uu][Aa]/,/Faculty/,/Theses/]
      match_regex.each do |r|
        if doc[:collection_id].match(r)
          doc[:university_archives] = true
          break
        end
      end
    end


    def add_resource_category(doc)
      match_regex = {
        'ua' => /^ua/,
        'mss' => /^m[cs]{1,2}/,
        'rb' => /^rb/
      }
      case self
      when Resource
        test_string = eadid
      when ArchivalObject
        test_string = resource.eadid
      end
      if test_string
        match_regex.each do |value,regex|
          if test_string.match(regex)
            doc[:resource_category] = value
            break
          end
        end
      end
    end


  end

end
