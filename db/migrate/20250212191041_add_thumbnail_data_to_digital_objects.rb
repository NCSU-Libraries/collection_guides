class AddThumbnailDataToDigitalObjects < ActiveRecord::Migration[7.2]
  def change
    add_column :digital_objects, :thumbnail_data, :text
  end
end
