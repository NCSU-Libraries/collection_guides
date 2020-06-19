class AddHasFilesToDigitalObjects < ActiveRecord::Migration[4.2]
  def change
    add_column :digital_objects, :has_files, :boolean
  end
end
