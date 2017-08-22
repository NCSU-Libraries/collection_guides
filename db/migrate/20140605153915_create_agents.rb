class CreateAgents < ActiveRecord::Migration
  def change
    create_table :agents do |t|
      t.string :uri
      t.string :display_name
      t.string :agent_type
      t.column(:api_response, 'longtext')
      t.timestamps
    end
    add_index :agents, :uri
    add_index :agents, :agent_type
  end
end
