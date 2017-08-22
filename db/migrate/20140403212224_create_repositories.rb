class CreateRepositories < ActiveRecord::Migration
  # using up/down instead of change because 'execute' is not reversible
  def up
    create_table(:repositories, :id => false) do |t|
      t.integer :id, :null => false
      t.string :uri, :null => false
      t.string :repo_code, :null => false
      t.string :org_code
      t.string :name, :null => false
      t.column(:api_response, 'longtext')
      t.timestamps
    end
    execute "ALTER TABLE `repositories` ADD PRIMARY KEY(id)"
    add_index :repositories, :repo_code
  end
  
  def down
    drop_table :repositories
  end
end
