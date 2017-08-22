class CreateDigitalObjectAssociations < ActiveRecord::Migration
  def change
    create_table :digital_object_associations do |t|
      t.integer :record_id
      t.string :record_type
      t.integer :digital_object_id
      t.integer :position
    end
    add_index :digital_object_associations, :digital_object_id
    add_index :digital_object_associations, :record_type
    add_index :digital_object_associations, :record_id
  end
end
