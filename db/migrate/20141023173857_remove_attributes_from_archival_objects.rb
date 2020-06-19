class RemoveAttributesFromArchivalObjects < ActiveRecord::Migration[4.2]
  def change
    remove_column :archival_objects, :master_seq
    remove_column :archival_objects, :structure
  end
end
