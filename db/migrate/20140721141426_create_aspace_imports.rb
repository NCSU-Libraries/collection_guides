class CreateAspaceImports < ActiveRecord::Migration[4.2]
  def change
    create_table :aspace_imports do |t|
      t.timestamps
    end
  end
end
