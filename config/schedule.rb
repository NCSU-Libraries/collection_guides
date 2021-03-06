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

  every "0 1-23 * * *" do
    rake "aspace_import:periodic"
  end

  every "0 0 * * 0" do
    rake "aspace_import:truncate_imports_table"
  end

  every "0 0 * * 1" do
    rake "marc_export:execute"
  end

  every "0 0 * * 2-6" do
    rake "aspace_import:truncate_imports_table"
  end


  # every "40 6-23 * * 1-6" do
  #   rake "search_index:hourly"
  # end

  # every "0 23 * * 2-6" do
  #   rake "aspace_import:daily"
  # end

  # every "0 3 * * 2-6" do
  #   rake "search_index:daily"
  # end

  # every "0 23 * * 0" do
  #   rake "aspace_import:weekly"
  # end

  # every "0 0 * * 1" do
  #   rake "search_index:full"
  # end


  # added after ArchivesSpace update - update date/time next time this is needed

  # every "0 13 25 9 *" do
  #   rake "aspace_import:full"
  # end

end
