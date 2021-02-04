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
      Resource.find_each { |r| r.update_unit_data }
    end
  end

  desc "update_tree_unit_data"
  task :update_tree_unit_data, [:id] => :environment do |t, args|
    UpdateResourceTreeUnitDataJob.perform_later(args[:id])
    # if args[:id]
    #   r = Resource.find args[:id]
    #   r.update_tree_unit_data
    # else
    #   Resource.find_each { |r| r.update_tree_unit_data }
    # end
  end

  desc "update_from_api"
  task :update_from_api, [:id] => :environment do |t, args|
    if args[:id]
      r = Resource.find args[:id]
      r.update_from_api
    else
      Resource.find_each { |r| r.update_from_api }
    end
  end

  desc "create_from_api"
  task :create_from_api, [:uri] => :environment do |t, args|
    if args[:uri]
      r = Resource.create_or_update_from_api(args[:uri])
      UpdateResourceTree.call(r.id)
    end
  end

  desc "update_tree"
  task :update_tree, [:id] => :environment do |t, args|

    call = lambda do |resource_id|
      UpdateResourceTreeJob.perform_later(r.id)
      puts "UpdateResourceTreeJob queued for Resource #{r.id}"
    end

    if args[:id]
      r = Resource.find args[:id]
      UpdateResourceTreeJob.perform_later(r.id)
    else
      Resource.find_each { |r| UpdateResourceTreeJob.perform_later(r.id) }
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
      Resource.find_each { |r| update_eadid.call(r) }
    end
    puts
  end

  desc "delete resource and all of its associations"
  task :delete, [:id] => :environment do |t, args|
    if args[:id]
      DeleteResource.call(args[:id])
    end
  end

end
