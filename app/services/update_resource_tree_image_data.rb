class UpdateResourceTreeImageData

  def initialize(resource, options={})
    @resource = resource
    @options = options
  end

  def self.call(resource, options={})
    new(resource, options).call
  end

  def call
    execute
  end

  private

  def execute
    puts "Updating resource tree image data for Resource #{@resource.id}"
    do_processed = 0
    do_updated = 0

    @resource.archival_objects.find_each do |ao|
      ao.digital_object_associations.each do |doa|

        if doa.digital_object.has_files
          updated = AddOrUpdateDigitalObjectImageData.call(doa.digital_object)
          do_processed += 1
          
          if updated
            do_updated += 1
            ao.update_unit_data
          end
        end
      end
    end

    puts "Processed #{do_processed} digital objects"
    puts "Updated #{do_updated} digital objects"
  end

end