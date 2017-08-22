namespace :archival_objects do

  desc "update_unit_data"
  task :update_unit_data, [:id] => :environment do |t, args|
    if args[:id]
      r = ArchivalObject.find args[:id]
    else
      ArchivalObject.update_unit_data
    end
  end

  desc "update_from_api"
  task :update_from_api, [:id] => :environment do |t, args|
    if args[:id]
      r = ArchivalObject.find args[:id]
      r.update_from_api
    else
      ArchivalObject.update_from_api
    end
  end

end
