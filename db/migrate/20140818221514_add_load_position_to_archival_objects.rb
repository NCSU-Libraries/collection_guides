class AddLoadPositionToArchivalObjects < ActiveRecord::Migration[4.2]
  def change
    add_column :archival_objects, :load_position, :integer
  end
end
