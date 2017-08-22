class CreateSubjectAssociations < ActiveRecord::Migration
  def change
    create_table :subject_associations do |t|
      t.integer :record_id
      t.string :record_type
      t.integer :subject_id
      t.string :function
      t.integer :position
      t.timestamps
    end
    add_index :subject_associations, :subject_id
    add_index :subject_associations, :record_type
    add_index :subject_associations, :record_id
  end
end
