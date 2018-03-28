require 'active_support/concern'

module AspaceConnect
  extend ActiveSupport::Concern

  included do
    require 'archivesspace-api-utility/helpers'
    include GeneralUtilities
    include AspaceUtilities
    include ArchivesSpaceApiUtility
    include ArchivesSpaceApiUtility::Helpers

    # Class method - If record of this class exists with given URI, update it from the API,
    # otherwise create a record of this class from data returned from URI
    # Params:
    # +uri+:: An ArchivesSpace URI associated with a single record
    # +options+:: Options passed from another method to be passed downstream
    def self.create_or_update_from_api(uri, options={})
      record = find_by_uri(uri)
      if record
        record.update_from_api(options)
      else
        record = create_record_from_api(uri, options)
      end
      record
    end

    # Class method - If record of this class exists with URI equal to that included in data,
    # update it from the API, otherwise create a record of this class from data returned from URI
    # Params:
    # +data+:: An ArchivesSpace response (JSON or Ruby)
    # +options+:: Options passed from another method to be passed downstream
    def self.create_or_update_from_data(data, options={})
      d = prepare_data(data)
      # r, json = d[:hash], d[:json]
      r = d[:hash]
      uri = r['uri']
      record = where(uri: uri).first
      if record
        record.update_from_data(data,options)
      else
        record = create_from_data(data,options)
      end

      record.reload
      record
    end

    # Class method - retrieve data from API corrsponding to uri
    def self.get_data_from_api(uri, options={})
      session = options[:session] || ArchivesSpaceApiUtility::ArchivesSpaceSession.new

      execute = Proc.new do
        response = session.get(uri, resolve: ['linked_agents','subjects','top_container'])
        if response.code.to_i == 200
          data = prepare_data(response.body)
          return (options[:format] == :json) ? data[:json] : data[:hash]
        elsif response.code.to_i == 412
          log_info "Session lost - establishing new"
          session = ArchivesSpaceApiUtility::ArchivesSpaceSession.new
          execute.call
        else
          nil
        end
      end

      execute.call
    end

    # Class method - Create a record of this class from data returned from URI
    # Params:
    # +uri+:: An ArchivesSpace URI associated with a single record
    # +options+:: Options passed from another method to be passed downstream
    def self.create_record_from_api(uri, options={})
      session = options[:session] || ArchivesSpaceApiUtility::ArchivesSpaceSession.new
      retries = 0

      execute = Proc.new do
        response = session.get(uri, resolve: ['linked_agents','subjects','top_container'])
        if response.code.to_i == 200
          create_from_data(response.body,options)
        elsif response.code.to_i == 412
          log_info "Session lost - establishing new"
          session = ArchivesSpaceApiUtility::ArchivesSpaceSession.new
          execute.call
        else
          if retries < 10
            retries += 1
            execute.call
          else
            raise response.body
          end
        end
      end

      execute.call
    end

    # Updates the record from the ArchivesSpace API
    # Params:
    # +options+:: Options passed from another method to be passed downstream (may include an active API session)
    def update_from_api(options={})
      session = options[:session] || ArchivesSpaceApiUtility::ArchivesSpaceSession.new
      retries = 0

      execute = Proc.new do
        response = session.get(self.uri, resolve: ['linked_agents','subjects','top_container'])
        if response.code.to_i == 200
          self.update_from_data(response.body,options)
        elsif response.code.to_i == 412
          log_info "Session lost - establishing new"
          session = ArchivesSpaceApiUtility::ArchivesSpaceSession.new
          execute.call
        else
          if retries < 10
            retries += 1
            execute.call
          else
            raise response.body
          end
        end
      end

      execute.call
    end

    def solr_get(query, params={})
      solr_url = "http://#{ENV['archivesspace_host']}:#{ENV['archivesspace_solr_port']}#{ENV['archivesspace_solr_path']}"
      @solr = RSolr.connect :url => solr_url
      @solr_params = {:q => query }
      @solr_params.merge! params
      @response = @solr.get 'select', :params => @solr_params
    end

  end
end
