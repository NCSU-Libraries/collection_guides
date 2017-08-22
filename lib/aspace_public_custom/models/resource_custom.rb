require 'active_support/concern'

module ResourceCustom
  extend ActiveSupport::Concern

  included do

    ### Custom class and instance methods


    def custom_test
      puts "This comes from ResourceCustom"
    end


    def update_unit_data_custom
      @data[:alt_digital_object_url] = alt_digital_object_url
    end


    # check associated URLs for descendants' digital objects
    # if any start with "http://d.lib.ncsu.edu/collections", generate url to canned search
    def alt_digital_object_url
      url = nil
      if !has_digital_objects && has_descendant_digital_objects
        generate_url = nil
        descendant_digital_objects.each do |d|
          if d.publish
            do_response_data = JSON.parse(d.api_response)
            if do_response_data['file_versions']
              do_response_data['file_versions'].each do |f|
                if f['publish']
                  uri = f["file_uri"]
                  if uri.match(/d\.lib\.ncsu\.edu\/collections/)
                    generate_url = true
                    break
                  end
                end
              end
            end
          end
          if generate_url
            break
          end
        end

        if generate_url && eadid
          url = 'http://d.lib.ncsu.edu/collections/catalog?f%5Beadid_facet%5D%5B%5D='
          url << eadid
        end
      end
      url
    end


    ### END - Custom class and instance methods

  end
end
