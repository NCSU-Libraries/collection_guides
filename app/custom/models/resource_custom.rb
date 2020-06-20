require 'active_support/concern'

module ResourceCustom
  extend ActiveSupport::Concern

  included do

    ### BEGIN - Custom methods

    def self.custom_test
      puts "This comes from ResourceCustom"
    end

    def update_unit_data_custom
      @data[:alt_digital_object_url] = alt_digital_object_url
    end

    # check associated URLs for descendants' digital objects
    # if ALL start with "http://d.lib.ncsu.edu/collections", generate url to canned search
    def alt_digital_object_url
      url = nil

      if !has_digital_objects_with_files
        dos = descendant_digital_objects_with_files

        if !dos.empty?
          has_non_sal_files = nil
          dos.each do |d|
            if d.publish
              do_response_data = JSON.parse(d.api_response)
              if do_response_data['file_versions']
                do_response_data['file_versions'].each do |f|
                  if !f['publish'] || !f["file_uri"]
                    has_non_sal_files = true
                    break
                  else
                    uri = f["file_uri"]
                    if !uri.match(/d\.lib\.ncsu\.edu\/collections/)
                      has_non_sal_files = true
                      break
                    end
                  end
                end
              end
            end
          end

          if !has_non_sal_files && eadid
            url = 'http://d.lib.ncsu.edu/collections/catalog?f%5Beadid_facet%5D%5B%5D='
            url << eadid
          end
        end
      end

      url
    end






    # THIS IS THE OLD VERSION OF THE METHOD ABOVE - IT WAS LESS RESTRICTIVE
    # check associated URLs for descendants' digital objects
    # if any start with "http://d.lib.ncsu.edu/collections", generate url to canned search

    # def alt_digital_object_url
    #   url = nil
    #   if !has_digital_objects && has_descendant_digital_objects
    #     generate_url = nil
    #     descendant_digital_objects.each do |d|
    #       if d.publish
    #         do_response_data = JSON.parse(d.api_response)
    #         if do_response_data['file_versions']
    #           do_response_data['file_versions'].each do |f|
    #             if f['publish']
    #               uri = f["file_uri"]
    #               if uri.match(/d\.lib\.ncsu\.edu\/collections/)
    #                 generate_url = true
    #                 break
    #               end
    #             end
    #           end
    #         end
    #       end
    #       if generate_url
    #         break
    #       end
    #     end

    #     if generate_url && eadid
    #       url = 'http://d.lib.ncsu.edu/collections/catalog?f%5Beadid_facet%5D%5B%5D='
    #       url << eadid
    #     end
    #   end
    #   url
    # end

    ### END - Custom methods

  end
end
