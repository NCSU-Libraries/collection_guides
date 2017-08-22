class AddStructureToResource < ActiveRecord::Migration
  def change
    add_column :resources, :structure, 'longtext'
  end
end
