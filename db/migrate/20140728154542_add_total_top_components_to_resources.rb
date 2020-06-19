class AddTotalTopComponentsToResources < ActiveRecord::Migration[4.2]
  def change
    add_column :resources, :total_top_components, :integer
  end
end
