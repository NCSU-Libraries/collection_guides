class CreateAgentAssociations < ActiveRecord::Migration
  def change
    create_table :agent_associations do |t|
      t.references :record, polymorphic: true
      t.integer :agent_id
      t.string :role
      t.string :function
      t.string :relator
      t.integer :position
      t.timestamps
    end
    add_index :agent_associations, :agent_id
    add_index :agent_associations, :record_type
    add_index :agent_associations, :record_id
  end
end
