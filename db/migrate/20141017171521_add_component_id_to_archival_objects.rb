class AddComponentIdToArchivalObjects < ActiveRecord::Migration[4.2]
  def change
    add_column :archival_objects, :component_id, :string
  end
end
