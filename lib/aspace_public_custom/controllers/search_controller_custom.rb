require 'active_support/concern'

module SearchControllerCustom
  extend ActiveSupport::Concern

  included do

    ### Custom methods/actions





    private

      def custom_test
        puts "This comes from SearchControllerCustom"
      end


      # Move NCSU subjects from agents to ncsu_subjects
      def process_custom_facets(params)
        if @facets['agents']
          @facets['ncsu_subjects'] = {}
          @facets['agents'].each do |agent,count|
            ncsu_regex_1 = /^North\sCarolina\sState\s((University)|(College))/
            ncsu_regex_2 = /^North\sCarolina\sCollege\sof\sAgriculture\sand\sMechanic\sArts/
            if agent.match(ncsu_regex_1) || agent.match(ncsu_regex_2)
              @facets['ncsu_subjects'][agent] = count
              @facets['agents'].delete(agent)
            end
          end
        end
      end


    ### END - Custom methods/actions

  end
end
