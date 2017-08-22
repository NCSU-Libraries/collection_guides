class AddComponentIdToArchivalObjects < ActiveRecord::Migration
  def change
    add_column :archival_objects, :component_id, :string
  end
end
