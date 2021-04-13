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


  desc "full import"
  task :full, [:page] => :environment do |t, args|
    # if add_task_pid('aspace_import')
    #   options = args[:page] ? {:page => args[:page].to_i} : {}
    #   Rake::Task['aspace_import:repositories'].invoke
    #   AspaceImport.execute_full(options)
    #   remove_task_pid('aspace_import')
    #   Rake::Task["aspace_import:purge_deleted"].invoke
    # end

    options = args[:page] ? {:page => args[:page].to_i} : {}
    AspaceImportFullJob.perform_later(options)
    Rake::Task['aspace_import:repositories'].invoke

  end


  # desc "delta import"
  # task :delta => :environment do |t, args|
  #   if add_task_pid('aspace_import')
  #     AspaceImport.execute_delta
  #     remove_task_pid('aspace_import')
  #     Rake::Task["aspace_import:purge_deleted"].invoke
  #   end
  # end


  desc "periodic import"
  task :periodic, [:num_hours] => :environment do |t, args|
    options = {}
    if args[:num_hours]
       options[:since] = args[:num_hours].to_i.hours.ago
    end
    ExecuteAspacePeriodicImport.call(options)
  end


  # desc "daily import"
  # task :daily => :environment do |t, args|
  #   AspaceImportDailyJob.perform_later
  #   puts "AspaceImportDailyJob added to the Resque import queue"
  # end


  # desc "hourly import"
  # task :hourly, [:num_hours] => :environment do |t, args|
  #   AspaceImportHourlyJob.perform_later
  #   puts "AspaceImportHourlyJob added to the Resque import queue"
  # end


  # desc "weekly import"
  # task :weekly, [:num_hours] => :environment do |t, args|
  #   AspaceImportWeeklyJob.perform_later
  #   puts "AspaceImportWeeklyJob added to the Resque import queue"
  # end


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
