class ArchivalObjectsController < ApplicationController

  include ArchivalObjectsHelper


  # Not a traditional show action. If params[:layout] == '0' will return raw HTML.
  def show
    @archival_object = ArchivalObject.find params[:id]
    if params[:format] == 'json'
      render text: @archival_object.api_response
    else
      if params[:layout] == '0'
        render text: archival_object_html(@archival_object, layout: false)
      else
        render
      end
    end
  end


  # Returns JSON data only
  def batch_html
    if params[:ids]
      @data = {}

      case params[:ids]
      when String
        ids = params[:ids].split(',')
      when Array
        ids = params[:ids]
      when Numeric
        ids = [params[:ids]]
      end
      ids.each do |id|
        archival_object = ArchivalObject.find id.to_i
        @data[id] = archival_object_html(archival_object, layout: false)
      end
      render :json => @data, :layout => false
    end
  end


  # Load custom methods if they exist
  begin
    include ArchivalObjectsControllerCustom
  rescue
  end

end
