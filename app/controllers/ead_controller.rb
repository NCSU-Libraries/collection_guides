class EadController < ApplicationController

  include EadExport

  def index
    puts params[:format]
    case params[:format]
    when 'html'
      @resources = Resource.paginate(:page => params[:page], :per_page => 100).order(:title)
    when 'txt'
      puts request.inspect
      list = ''
      Resource.order(:title).find_each do |r|
        list << "#{request.protocol}#{request.host_with_port}#{root_path}#{r.eadid}/ead"
        list << "\n"
      end
      render plain: list
    end
  end


  def show
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
      @ead = EadRecord.new(resource_id: @resource.id)
      render xml: @ead.generate
    end
  end


  # Load custom methods if they exist
  begin
    include EadControllerCustom
  rescue
  end

end
