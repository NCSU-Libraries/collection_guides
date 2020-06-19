class AddDigitalObjectVolumesVolumeId < ActiveRecord::Migration[4.2]
  def change
    add_column :digital_object_volumes, :volume_id, :integer
  end
end
