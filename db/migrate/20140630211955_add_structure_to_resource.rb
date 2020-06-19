class AddStructureToResource < ActiveRecord::Migration[4.2]
  def change
    add_column :resources, :structure, 'longtext'
  end
end
