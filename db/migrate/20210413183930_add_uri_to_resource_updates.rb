class AddUriToResourceUpdates < ActiveRecord::Migration[5.2]
  def change
    add_column :resource_tree_updates, :resource_uri, :string
  end
end
