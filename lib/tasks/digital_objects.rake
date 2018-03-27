namespace :digital_objects do

  desc "enable_thumbnails_for_resource"
  task :enable_thumbnails_for_resource, [:id] => :environment do |t, args|
    if args[:id]
      r = Resource.find args[:id]

      # puts "Updating digital objects linked to resource..."
      # r.digital_objects.each do |d|
      #   d.update_attributes(show_thumbnails: true)
      # end

      puts "Updating digital objects linked to archival objects..."
      r.archival_objects.each do |a|
        a.digital_objects.each do |d|
          d.update_attributes(show_thumbnails: true)
        end
      end

      puts "Updating tree unit data..."
      r.update_tree_unit_data
    end
  end

  desc "update has_files field"
  task :update_has_files, [:id] => :environment do |t, args|
    if args[:id]
      puts "updating has_files for DigitalObject #{ args[:id] }"
      dao = DigitalObject.find args[:id]
      dao.update_has_files
    else
      puts "updating has_files for all digital objects"
      DigitalObject.find_each do |dao|
        dao.update_has_files
        print '.'
      end
    end
  end

end
