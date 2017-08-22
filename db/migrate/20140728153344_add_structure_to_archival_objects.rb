class AddStructureToArchivalObjects < ActiveRecord::Migration
  def change
    add_column :archival_objects, :structure, 'longtext'
  end
end
