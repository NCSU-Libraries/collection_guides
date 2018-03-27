class CreateResources < ActiveRecord::Migration
  # using up/down instead of change because 'execute' is not reversible
  def up
    create_table(:resources, :id => false) do |t|
      t.integer :id, :null => false
      t.string :uri, :null => false
      t.integer :repository_id, :null => false
      t.string :title, :limit => 8704
      t.boolean :publish
      t.column(:api_response, 'longtext')
      t.timestamps
    end
    add_index :resources, :uri
    add_index :resources, :repository_id
  end

  def down
    drop_table :resources
  end
end
