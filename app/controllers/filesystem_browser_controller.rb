class FilesystemBrowserController < ApplicationController

  def show
    @volume_id = params[:volume_id]
    puts @volume_id
  end

end
