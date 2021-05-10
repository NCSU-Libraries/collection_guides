class HandleBadEncodingMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      Rack::QueryParser.parse_nested_query(env['QUERY_STRING'].to_s)
    rescue Rack::QueryParser::InvalidParameterError
      env['QUERY_STRING'] = ''
    end
    
    @app.call(env)
  end
end