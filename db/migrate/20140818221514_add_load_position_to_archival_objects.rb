class AddLoadPositionToArchivalObjects < ActiveRecord::Migration
  def change
    add_column :archival_objects, :load_position, :integer
  end
end
