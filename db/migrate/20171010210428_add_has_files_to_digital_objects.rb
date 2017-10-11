class AddHasFilesToDigitalObjects < ActiveRecord::Migration
  def change
    add_column :digital_objects, :has_files, :boolean
  end
end
