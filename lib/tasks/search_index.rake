require 'modules/task_master'
include TaskMaster

namespace :search_index do

  desc "full clean index"
  task :full_clean => :environment do |t, args|
    # if add_task_pid('search_index')
    #   s = SearchIndex.new
    #   s.execute_full(clean: true)
    #   remove_task_pid('search_index')
    # end
    SearchIndexFullJob.perform_later(clean: true)
  end

  desc "full index"
  task :full => :environment do |t, args|
    # if add_task_pid('search_index')
    #   s = SearchIndex.new
    #   s.execute_full
    #   remove_task_pid('search_index')
    # end
    SearchIndexFullJob.perform_later
  end

  desc "delta index"
  task :delta => :environment do |t, args|
    # if add_task_pid('search_index')
    #   s = SearchIndex.new
    #   s.execute_delta
    #   remove_task_pid('search_index')
    # end
    SearchIndexPartialJob.perform_later('delta')
  end

  desc "hourly index"
  task :hourly => :environment do |t, args|
    # if add_task_pid('search_index')
    #   s = SearchIndex.new
    #   s.execute_hourly
    #   remove_task_pid('search_index')
    # end
    SearchIndexPartialJob.perform_later('hourly')
  end

  desc "daily index"
  task :daily => :environment do |t, args|
    # if add_task_pid('search_index')
    #   s = SearchIndex.new
    #   s.execute_daily
    #   remove_task_pid('search_index')
    # end
    SearchIndexPartialJob.perform_later('daily')
  end

  desc "index single resource"
  task :resource, [:id] => :environment do |t, args|
    r = Resource.find args[:id]
    SearchIndex.update_record(r)
  end

  desc "index resource tree"
  task :resource_tree, [:resource_id] => :environment do |t, args|
    if !args[:resource_id]
      puts ":resource_id is required"
    else
      SearchIndexResourceTreeJob.perform_later(args[:resource_id].to_i)
    end
  end

  desc "index single archival_object"
  task :archival_object, [:id] => :environment do |t, args|
    r = ArchivalObject.find args[:id]
    SearchIndex.update_record(r)
  end

  desc "delete single record with given uri"
  task :delete_record_by_uri, [:uri] => :environment do |t, args|
    SearchIndex.delete_record_by_uri(args[:uri])
  end

  desc "check solr"
  task :check_solr, [:uri] => :environment do |t, args|
    solr = SearchIndex.check_solr
    puts solr.inspect
  end


  desc "temporary task to populate new index while keeping the old one alive"
  task :populate_new_index => :environment do |t, args|
    if add_task_pid('search_index')
      solr_url = "http://#{ENV['solr_host']}:8983/solr/collection_guides/"
      puts "Populating Solr index at #{ solr_url }"
      s = SearchIndex.new
      s.execute_full(solr_url: solr_url)
      remove_task_pid('search_index')
    end
  end

end
