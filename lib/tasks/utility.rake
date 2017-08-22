require 'modules/task_master'
include TaskMaster

namespace :utility do

  desc "clear_all_pids"
  task :clear_all_pids => :environment do |t, args|
    clear_all_pids()
  end

end

