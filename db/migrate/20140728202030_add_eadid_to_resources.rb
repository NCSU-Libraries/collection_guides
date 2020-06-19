class AddEadidToResources < ActiveRecord::Migration[4.2]
  def change
    add_column :resources, :eadid, :string
  end
end
