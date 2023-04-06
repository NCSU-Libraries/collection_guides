class UpdateAspaceImports < ActiveRecord::Migration[5.2]
  def change
    remove_column :aspace_imports, :archival_objects_updated, :integer
    add_column :aspace_imports, :import_errors, :integer
  end
end
