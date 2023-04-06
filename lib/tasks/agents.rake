namespace :agents do

  desc "update_from_api"
  task :update_from_api, [:id] => :environment do |t, args|
     UpdateAgentsFromApiJob.perform_later(args[:id])
  end

end
