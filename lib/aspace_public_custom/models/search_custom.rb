require 'active_support/concern'

module SearchCustom
  extend ActiveSupport::Concern

  included do


    ### Custom class and instance methods


    def custom_test
      puts "This comes from SearchCustom"
    end


    def custom_query_fields
      @query_fields['collection_id_split'] = nil
    end


    def custom_solr_params
      @solr_params[:bq] << "record_type:resource^800"
      if @q
        @solr_params[:bq] << "collection_id:\"#{@q.gsub(/\"/,'')}\"^1000000"
      end
    end


    ### END - Custom class and instance methods


  end

end
