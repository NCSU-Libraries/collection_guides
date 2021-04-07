class CreateResourceTreeUpdates < ActiveRecord::Migration[5.2]
  def change
    create_table :resource_tree_updates do |t|
      t.integer :resource_id
      t.datetime :completed_at
      t.integer :exit_status
      t.text :error
      t.timestamps
    end
  end
end
