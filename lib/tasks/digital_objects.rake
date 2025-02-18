namespace :digital_objects do

  desc "enable_thumbnails_for_resource"
  task :enable_thumbnails_for_resource, [:id] => :environment do |t, args|
    if args[:id]
      r = Resource.find args[:id]

      # puts "Updating digital objects linked to resource..."
      # r.digital_objects.each do |d|
      #   d.update!(show_thumbnails: true)
      # end

      puts "Updating digital objects linked to archival objects..."
      r.archival_objects.each do |a|
        a.digital_objects.each do |d|
          d.update!(show_thumbnails: true)
        end
      end

      puts "Updating tree unit data..."
      r.update_tree_unit_data
    end
  end

  desc "add image_data from Sal"
  task :add_image_data, [:id] => :environment do |t, args|
    if args[:id]
      if d = DigitalObject.find_by(id: args[:id].to_i)
        puts "Updating DigitalObject #{d.id}..."
        AddOrUpdateDigitalObjectImageData.call(d)
      end
    else
      DigitalObject.find_each do |d|
        if r = AddOrUpdateDigitalObjectImageData.call(d)
          print '+'
        else
          print '.'
        end
      end
    end
  end

end
