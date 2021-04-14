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


  desc "periodic import"
  task :periodic, [:num_hours] => :environment do |t, args|
    options = {}
    if args[:num_hours]
       options[:since] = args[:num_hours].to_i.hours.ago
    end
    ExecuteAspacePeriodicImport.call(options)
  end


  desc "purge deleted"
  task :purge_deleted => :environment do |t, args|
    PurgeDeletedResources.call
  end


  desc "remove import old records from aspace_imports table"
  task :truncate_imports_table => :environment do |t, args|
    cutoff = Date.today - 30.days
    AspaceImport.where("created_at < '#{ cutoff.to_s }'").each { |i| i.destroy }
  end


  desc "remove import old records from resource_tree_updates table"
  task :truncate_imports_table => :environment do |t, args|
    cutoff = Date.today - 60.days
    ResourceTreeUpdate.where("created_at < '#{ cutoff.to_s }'").each { |i| i.destroy }
  end

end
