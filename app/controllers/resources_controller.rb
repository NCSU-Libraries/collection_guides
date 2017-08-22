class ResourcesController < ApplicationController

  include AspaceContentUtilities
  include ResourcesHelper

  def index
  end

  def show

    # Provided to facilitate indexing by Google
    # SEE: https://developers.google.com/webmasters/ajax-crawling/docs/specification
    @escaped_fragment = params[:_escaped_fragment_] ? true : false

    if params[:id]
      begin
        @resource = Resource.find params[:id]
      rescue Exception => e
        redirect_to root_url, alert: "Collection not found."
        return
      end
    elsif params[:eadid]
      @resource = Resource.find_by_eadid(params[:eadid])
    else
      @resource = nil
    end

    if !@resource
      redirect_to root_url, alert: "Collection not found."
      return
    else
      @presenter = @resource.presenter
      @tab = params[:tab] || 'summary'

      respond_to do |format|
        format.html
        format.xml do
          redirect_to "#{root_path}#{@resource.eadid}"
        end
      end

    end
  end


  # Load custom methods if they exist
  begin
    include ResourcesControllerCustom
  rescue
  end

end
