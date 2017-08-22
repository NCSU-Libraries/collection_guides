namespace :digital_object_volumes do

  desc "create digital_object_volume"
  task :create, [:digital_object_id, :volume_id, :position] => :environment do |t, args|
    options = {
      digital_object_id: args[:digital_object_id].to_i,
      volume_id: args[:volume_id],
      position: args[:position] ? args[:position].to_i : 1
    }

    puts options.inspect

    d = DigitalObject.find options[:digital_object_id]

    if d
      dov = DigitalObjectVolume.find_or_create_by(options)
      puts dov.inspect
      d.archival_objects.each do |ao|
        ao.update_unit_data
      end
      d.resources.each do |r|
        r.update_unit_data
      end
    end
  end

end
