class CreateSubjects < ActiveRecord::Migration[4.2]

  def up
    create_table(:subjects, :id => false) do |t|
      t.integer :id, :null => false
      t.string :uri
      t.string :subject
      t.string :subject_root
      t.string :subject_type
      t.string :subject_source_uri
      t.column(:api_response, 'longtext')
      t.timestamps
    end
    add_index :subjects, :uri
    add_index :subjects, :subject_type
  end

  def down
    drop_table :subjects
  end



end
