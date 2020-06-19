class AddMasterSeqToArchivalObjects < ActiveRecord::Migration[4.2]
  def change
    add_column :archival_objects, :master_seq, :integer
  end
end
