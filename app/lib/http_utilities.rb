module HttpUtilities

    # returns hash that includes URI, request object and response from HTTP request
    def execute_http_request(uri, request, raise_http_errors=true, limit=10, retry_on_timeout=true)
      raise 'HTTP redirect too deep' if limit == 0

      use_ssl = uri.to_s.match(/https:/)
      response = { uri: uri, request: request }
      retried = false
      begin
      Net::HTTP.start(uri.hostname, uri.port, :use_ssl => use_ssl) do |http|
        http_response = http.request(request)

        case http_response
        when Net::HTTPSuccess
          response[:response] = http_response
        when Net::HTTPRedirection
          location = http_response['location']
          new_uri = URI(location)
          response = execute_http_request(new_uri, request_for_method(request.method.downcase.to_sym, new_uri), raise_http_errors, limit - 1)
        else
          message = "HTTP error from #{uri}: #{http_response.code} - #{http_response.message}"
          raise message if raise_http_errors
          response[:error] = message
        end
      end
      rescue Net::ReadTimeout, Net::OpenTimeout
        if retry_on_timeout && !retried
          retried = true
          retry
        else
          response[:error] = 'Request timed out'
        end
      end

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


    def get_data_from_url(url, raise_http_errors=true)
      uri = URI(url)
      req = request_for_method(:get, uri)
      execute_http_request(uri, req, raise_http_errors)
    end

  end