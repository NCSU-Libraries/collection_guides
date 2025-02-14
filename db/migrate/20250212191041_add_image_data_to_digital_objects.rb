class AddImageDataToDigitalObjects < ActiveRecord::Migration[7.2]
  def change
    add_column :digital_objects, :image_data, :text
  end
end
