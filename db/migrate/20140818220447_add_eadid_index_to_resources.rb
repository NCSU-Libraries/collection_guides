class AddEadidIndexToResources < ActiveRecord::Migration[4.2]
  def change
    add_index :resources, :eadid
  end
end
