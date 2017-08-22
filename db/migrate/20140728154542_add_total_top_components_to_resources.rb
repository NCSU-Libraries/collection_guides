class AddTotalTopComponentsToResources < ActiveRecord::Migration
  def change
    add_column :resources, :total_top_components, :integer
  end
end
