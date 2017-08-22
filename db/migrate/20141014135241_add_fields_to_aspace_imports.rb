class AddFieldsToAspaceImports < ActiveRecord::Migration
  def change
    add_column :aspace_imports, :import_type, :string
    add_column :aspace_imports, :resources_updated, :integer
    add_column :aspace_imports, :archival_objects_updated, :integer
  end
end
