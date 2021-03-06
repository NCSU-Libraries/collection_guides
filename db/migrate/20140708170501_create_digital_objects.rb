class CreateDigitalObjects < ActiveRecord::Migration[4.2]
  def up
    create_table :digital_objects, :id => false do |t|
      t.integer :id, :null => false
      t.string :uri, :null => false
      t.integer :repository_id, :null => false
      t.string :title, :limit => 8704
      t.string :digital_object_id
      t.boolean :publish
      t.column(:api_response, 'longtext')
      t.timestamps
    end
    add_index :digital_objects, :uri
  end

  def down
    drop_table :digital_objects
  end

end
