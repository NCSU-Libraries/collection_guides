class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include SitemapGenerator

  # Load custom methods if they exist
  begin
    include ApplicationControllerCustom
  rescue
  end

  rescue_from ActionController::BadRequest, with: :bad_request


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
    @title = "Help"
    render
  end

  def not_found
    redirect_to root_url, alert: "Page not found.", status: 404
  end


  private


  def bad_request
    flash[:error] = "Bad request"
    redirect_to '/'
  end
  

end
