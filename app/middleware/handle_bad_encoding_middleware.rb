class HandleBadEncodingMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      Rack::Utils.parse_nested_query(env['QUERY_STRING'].to_s)
    rescue Rack::QueryParser::InvalidParameterError
      env['QUERY_STRING'] = ''
    end

    begin
      @app.call(env)
    rescue Rack::QueryParser::InvalidParameterError
      env['QUERY_STRING'] = ''
      @app.call(env)
    end
  end
end