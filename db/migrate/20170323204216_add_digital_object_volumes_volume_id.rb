class AddDigitalObjectVolumesVolumeId < ActiveRecord::Migration
  def change
    add_column :digital_object_volumes, :volume_id, :integer
  end
end
