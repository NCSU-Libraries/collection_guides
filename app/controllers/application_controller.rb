class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include SitemapGenerator

  def index
    render
  end

  def sitemap
    @base_url = request.base_url + root_path
    sitemap = Sitemap.new(@base_url)
    xml = sitemap.generate
    render :xml => xml
  end

  def help
    render
  end

  def not_found
    render status: 404
  end

  # Load custom methods if they exist
  begin
    include ApplicationControllerCustom
  rescue
  end

end
