class AddMasterSeqToArchivalObjects < ActiveRecord::Migration
  def change
    add_column :archival_objects, :master_seq, :integer
  end
end
