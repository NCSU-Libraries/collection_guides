class AddTotalComponentsToResources < ActiveRecord::Migration
  def change
    add_column :resources, :total_components, :integer
  end
end
