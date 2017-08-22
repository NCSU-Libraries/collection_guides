class CreateArchivalObjects < ActiveRecord::Migration
  # using up/down instead of change because 'execute' is not reversible
  def up
    create_table :archival_objects, :id => false do |t|
      t.integer :id, :null => false
      t.string :uri, :null => false
      t.string :title, :limit => 8704
      t.boolean :publish
      t.integer :parent_id
      t.integer :resource_id
      t.integer :repository_id, :null => false
      t.string :level
      t.integer :position
      t.column(:api_response, 'longtext')
      t.timestamps
    end
    execute "ALTER TABLE `archival_objects` ADD PRIMARY KEY(id)"
    add_index :archival_objects, :uri
    add_index :archival_objects, :parent_id
    add_index :archival_objects, :resource_id
    add_index :archival_objects, :repository_id
  end

  def down
    drop_table :archival_objects
  end
end
