module HttpUtilities

    # returns hash that includes URI, request object and response from HTTP request
    def execute_http_request(uri, request, raise_http_errors=true)
      use_ssl = uri.to_s.match(/https:/)
      response = { uri: uri, request: request }
      Net::HTTP.start(uri.hostname, uri.port, :use_ssl => use_ssl) do |http|
        http_response = http.request(request)
  
        if !http_response.kind_of?(Net::HTTPSuccess)
          message = "HTTP error from #{uri}: #{http_response.code} - #{http_response.message}"

          if raise_http_errors
            raise message
          end
          response[:error] = message
        end
  
        response[:response] = http_response
      end
  
      # log_info(response.inspect)
      response
    end
  
    def request_for_method(method, uri)
      case method
      when :post
        req = Net::HTTP::Post.new(uri)
      when :patch
        req = Net::HTTP::Patch.new(uri)
      when :delete
        req = Net::HTTP::Delete.new(uri)
      else
        req = Net::HTTP::Get.new(uri)
      end
        req['Content-type'] = 'application/json'
      req
    end


    def get_data_from_url(url)
      uri = URI(url)
      req = request_for_method(:get, uri)
      execute_http_request(uri, req)
    end

  end