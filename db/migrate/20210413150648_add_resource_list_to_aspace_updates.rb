class AddResourceListToAspaceUpdates < ActiveRecord::Migration[5.2]
  def change
    add_column :aspace_imports, :resource_list, :text
  end
end
