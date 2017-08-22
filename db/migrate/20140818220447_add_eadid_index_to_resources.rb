class AddEadidIndexToResources < ActiveRecord::Migration
  def change
    add_index :resources, :eadid
  end
end
