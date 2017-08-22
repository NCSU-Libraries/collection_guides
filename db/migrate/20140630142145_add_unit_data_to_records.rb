class AddUnitDataToRecords < ActiveRecord::Migration
  def change
    add_column :resources, :unit_data, 'longtext'
    add_column :archival_objects, :unit_data, 'longtext'
  end
end
