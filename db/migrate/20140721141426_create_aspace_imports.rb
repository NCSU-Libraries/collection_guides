class CreateAspaceImports < ActiveRecord::Migration
  def change
    create_table :aspace_imports do |t|
      t.timestamps
    end
  end
end
