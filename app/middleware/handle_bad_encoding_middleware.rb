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

    @app.call(env)
  end
end