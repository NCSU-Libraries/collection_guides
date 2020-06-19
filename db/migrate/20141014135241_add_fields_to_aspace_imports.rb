class AddFieldsToAspaceImports < ActiveRecord::Migration[4.2]
  def change
    add_column :aspace_imports, :import_type, :string
    add_column :aspace_imports, :resources_updated, :integer
    add_column :aspace_imports, :archival_objects_updated, :integer
  end
end
