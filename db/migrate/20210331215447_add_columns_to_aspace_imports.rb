class AddColumnsToAspaceImports < ActiveRecord::Migration[5.2]
  def change
    add_column :aspace_imports, :total_updates, :integer
  end
end
