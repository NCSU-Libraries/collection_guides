class SearchIndexResourceTreeJob < ApplicationJob
  queue_as :index

  def perform(resource_id)
    update_record = lambda do |record|
      record.update_index
      print '.'
    end

    r = Resource.find resource_id

    puts "Updating index for all records in Resource #{resource_id}"

    update_record.(r)

    r.digital_objects.each do |d|
      update_record.(d)
    end

    r.archival_objects.each do |ao|
      update_record.(ao)
      ao.digital_objects.each do |d|
        update_record.(d)
      end
    end
    puts
  end

end
