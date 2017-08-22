namespace :resources do

  desc "update hierarchy attributes"
  task :update_hierarchy_attributes, [:start] => :environment do |t, args|
    Resource.update_hierarchy_attributes(start: args[:start])
  end

  desc "update_unit_data"
  task :update_unit_data, [:id] => :environment do |t, args|
    if args[:id]
      r = Resource.find args[:id]
      r.update_unit_data
    else
      Resource.update_unit_data
    end
  end


  desc "update_tree_unit_data"
  task :update_tree_unit_data, [:id] => :environment do |t, args|
    if args[:id]
      r = Resource.find args[:id]
      r.update_tree_unit_data
    else
      Resource.find_each { |r| r.update_tree_unit_data }
    end
  end


  desc "update_from_api"
  task :update_from_api, [:id] => :environment do |t, args|
    if args[:id]
      r = Resource.find args[:id]
      r.update_from_api
    else
      Resource.update_from_api
    end
  end


  desc "create_from_api"
  task :create_from_api, [:uri] => :environment do |t, args|
    if args[:uri]
      r = Resource.create_or_update_from_api(args[:uri])
      r.update_tree_from_api
    end
  end


  desc "update_tree_from_api"
  task :update_tree_from_api, [:id] => :environment do |t, args|
    if args[:id]
      r = Resource.find args[:id]
      r.update_tree_from_api
    else
      Resource.update_tree_from_api
    end
  end


  desc "generate eadid"
  task :update_eadid, [:id] => :environment do |t, args|
    include GeneralUtilities
    update_eadid = Proc.new do |resource|
      data = resource.parse_unit_data
      id_0 = data[:id_0]
      eadid = slugify(id_0)
      resource.update_attributes(:eadid => eadid)
      print '.'
    end

    if args[:id]
      r = Resource.find args[:id]
      update_eadid.call(r)
    else
      Resource.find_each { |rr| update_eadid.call(r) }
    end
    puts
  end

end
