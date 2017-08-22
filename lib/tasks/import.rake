require 'modules/task_master'
include TaskMaster

include ArchivesSpaceApiUtility

namespace :aspace_import do

  desc "import repositories"
  task :repositories => :environment do |t, args|
    include AspaceUtilities
    a = ArchivesSpaceSession.new
    response = a.get('/repositories', resolve: ['agent_representation'])
    if response.code.to_i == 200
      repositories = JSON.parse(response.body)
      repositories.each do |r|
        existing_repository = Repository.where(uri: r['uri']).first
        if existing_repository
          puts "Repository #{r['uri']} exists - updating..."
          existing_repository.update_from_api
        else
          puts "Creating repository #{r['uri']}..."
          Repository.create_from_api(r['uri'])
        end
      end
    else
      raise response.body
    end
  end


  desc "import resources only (per repository)"
  task :resources => :environment do |t, args|
    AspaceImport.execute_by_type('resource')
  end


  desc "import archival_objects (per repsitory)"
  task :archival_objects, [:page] => :environment do |t, args|
    options = args[:page] ? {:page => args[:page].to_i} : {}
    AspaceImport.execute_by_type('archival_object', options)
    ArchivalObject.update_has_children
  end


  desc "full import"
  task :full, [:page] => :environment do |t, args|
    if add_task_pid('aspace_import')
      options = args[:page] ? {:page => args[:page].to_i} : {}
      Rake::Task['aspace_import:repositories'].invoke
      AspaceImport.execute_full(options)
      remove_task_pid('aspace_import')
      Rake::Task["aspace_import:purge_deleted"].invoke
    end
  end


  desc "delta import"
  task :delta => :environment do |t, args|
    if add_task_pid('aspace_import')
      AspaceImport.execute_delta
      remove_task_pid('aspace_import')
      Rake::Task["aspace_import:purge_deleted"].invoke
    end
  end


  desc "daily import"
  task :daily => :environment do |t, args|
    if add_task_pid('aspace_import')
      AspaceImport.execute_daily
      remove_task_pid('aspace_import')
      Rake::Task["aspace_import:purge_deleted"].invoke
    end
  end


  desc "hourly import"
  task :hourly, [:num_hours] => :environment do |t, args|
    if add_task_pid('aspace_import')
      AspaceImport.execute_hourly(args[:num_hours])
      remove_task_pid('aspace_import')
      Rake::Task["aspace_import:purge_deleted"].invoke
    end
  end



  desc "purge deleted"
  task :purge_deleted => :environment do |t, args|
    if add_task_pid('aspace_import_purge_deleted')
      AspaceImport.purge_deleted
      remove_task_pid('aspace_import_purge_deleted')
    end
  end


  desc "remove import old records from db"
  task :truncate_imports_table => :environment do |t, args|
    cutoff = Date.today - 30
    AspaceImport.where("created_at < '#{ cutoff.to_s }'").each { |i| i.destroy }
  end

end
