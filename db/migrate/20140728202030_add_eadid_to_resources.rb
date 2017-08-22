class AddEadidToResources < ActiveRecord::Migration
  def change
    add_column :resources, :eadid, :string
  end
end
