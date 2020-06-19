class RemoveFilesystemBrowseUrl < ActiveRecord::Migration[4.2]
  def change
    remove_column :digital_object_volumes, :filesystem_browse_url
  end
end
