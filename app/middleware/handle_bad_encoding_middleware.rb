# This file exists to deal with various attempts by malicious bots to attack the site!

class HandleBadEncodingMiddleware
  
  def initialize(app)
    @app = app
  end

  def call(env)
    # If issues can are limited to query string just clear that
    begin
      # Non-UTF characters in the query string
      Rack::Utils.parse_nested_query(env['QUERY_STRING'].to_s)
    rescue Rack::Utils::InvalidParameterError, Rack::QueryParser::InvalidParameterError, ActionController::BadRequest
      env['QUERY_STRING'] = ''
    end

    begin
      # If issues can are lin other parts of the URL, tell the bot to go to hell
      uri = Rack::Utils.unescape(env['REQUEST_URI'])
      
      # Very long URLs that are mostly '//.'
      if uri && uri.length > 1000
        raise ActionController::BadRequest
      end

      # Non-UTF characters in the URL
      Rack::Utils.parse_nested_query(uri)
      
      @app.call(env)
    rescue Rack::Utils::InvalidParameterError, Rack::QueryParser::InvalidParameterError, ActionController::BadRequest
      redirect_path = (env['ORIGINAL_SCRIPT_NAME'] ==  '/findingaids') ? '/findingaids' : '/'
      return [301, {'Location' => redirect_path, 'Content-Type' => 'text/html'}, ['Nice try']]
    end
  end

end