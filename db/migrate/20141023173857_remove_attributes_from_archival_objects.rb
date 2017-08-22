class RemoveAttributesFromArchivalObjects < ActiveRecord::Migration
  def change
    remove_column :archival_objects, :master_seq
    remove_column :archival_objects, :structure
  end
end
