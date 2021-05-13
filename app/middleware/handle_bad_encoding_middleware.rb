class HandleBadEncodingMiddleware
  
  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      Rack::Utils.parse_nested_query(env['QUERY_STRING'].to_s)
    rescue Rack::Utils::InvalidParameterError, Rack::QueryParser::InvalidParameterError, ActionController::BadRequest
      env['QUERY_STRING'] = ''
    end

    begin
      uri = Rack::Utils.unescape(env['REQUEST_URI'])
      if uri && uri.length > 1000
        raise ActionController::BadRequest
      end
      Rack::Utils.parse_nested_query(uri)
      @app.call(env)
    rescue Rack::Utils::InvalidParameterError, Rack::QueryParser::InvalidParameterError, ActionController::BadRequest
      redirect_path = (env['ORIGINAL_SCRIPT_NAME'] ==  '/findingaids') ? '/findingaids' : '/'
      return [301, {'Location' => redirect_path, 'Content-Type' => 'text/html'}, ['Nice try']]
    end
  end

end