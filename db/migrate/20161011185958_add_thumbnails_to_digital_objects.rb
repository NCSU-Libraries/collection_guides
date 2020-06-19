class AddThumbnailsToDigitalObjects < ActiveRecord::Migration[4.2]
  def change
    add_column :digital_objects, :show_thumbnails, :boolean
  end
end
