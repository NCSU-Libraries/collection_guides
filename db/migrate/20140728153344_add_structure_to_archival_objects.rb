class AddStructureToArchivalObjects < ActiveRecord::Migration[4.2]
  def change
    add_column :archival_objects, :structure, 'longtext'
  end
end
