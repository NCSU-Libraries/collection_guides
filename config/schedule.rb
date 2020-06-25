# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#

# every 1.hours do
#   command "echo 'TEST'"
# end


if @environment == 'production'

  every "0 6-23 * * 1-6" do
    rake "aspace_import:hourly"
  end

  every "0 0 * * 2-6" do
    rake "aspace_import:daily"
  end

  every "0 0 * * 7" do
    rake "aspace_import:weekly"
  end

  every "0 0 * * 1" do
    rake "aspace_import:truncate_imports_table"
  end

  # every "40 6-23 * * 1-6" do
  #   rake "search_index:hourly"
  # end

  # every "0 3 * * 2-6" do
  #   rake "search_index:daily"
  # end

  #   every "0 12 * * 2" do
  #     rake "marc_export:execute"
  #   end

  # every "0 0 * * 1" do
  #   rake "search_index:full"
  # end

end
