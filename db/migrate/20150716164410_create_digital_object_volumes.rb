class CreateDigitalObjectVolumes < ActiveRecord::Migration
  def change
    create_table :digital_object_volumes do |t|
      t.integer :digital_object_id, :null => false
      t.integer :position, :null => false
      t.string :filesystem_browse_url
      t.timestamps
    end
  end
end
