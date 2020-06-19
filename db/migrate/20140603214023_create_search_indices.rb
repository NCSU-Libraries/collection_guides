class CreateSearchIndices < ActiveRecord::Migration[4.2]
  def change
    create_table :search_indices do |t|
      t.string :index_type
      t.integer :records_updated
      t.timestamps
    end
  end
end
