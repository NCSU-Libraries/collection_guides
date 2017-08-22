class AddThumbnailsToDigitalObjects < ActiveRecord::Migration
  def change
    add_column :digital_objects, :show_thumbnails, :boolean
  end
end
