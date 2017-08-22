class AddHasChildrenToRecords < ActiveRecord::Migration
  def change
    add_column :resources, :has_children, :boolean
    add_column :archival_objects, :has_children, :boolean
  end
end
