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

  desc "update image_data from Sal for recently updated digital_objects"
  task :update_image_data_daily, [:days] => :environment do |t, args|
    days = args[:days] || 1
    puts "Updating digital objects updated in last #{days} days..."
    where_time = Time.now - days.to_i.days
    resource_ids = []
    DigitalObject.where('updated_at >= ? AND created_at < ?', where_time, where_time).find_each do |d|
      puts d.inspect
      UpdateDigitalObjectImageDataJob.perform_later(d)
      d.archival_objects.each { |ao| resource_ids << ao.resource_id }
      resource_ids.uniq!
    end

    resource_ids.each do |rid|
      UpdateResourceTreeUnitDataJob.perform_later(rid)
    end
  end

end
