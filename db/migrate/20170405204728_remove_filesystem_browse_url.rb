class RemoveFilesystemBrowseUrl < ActiveRecord::Migration
  def change
    remove_column :digital_object_volumes, :filesystem_browse_url
  end
end
