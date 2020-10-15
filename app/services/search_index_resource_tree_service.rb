class SearchIndexResourceTreeService < SearchIndexServiceBase


  private


  def execute
    @response = {}

    if !@options[:resource_id]
      @response[:error] = ":resource_id is required"
    else
      @response[:records_indexed] = {
        resources: 0,
        archival_objects: 0
      }

      @r = Resource.find @options[:resource_id]
      puts "Updating tree for Resource #{@options[:resource_id]}"

      if update_record(@r)
        @response[:records_indexed][:resources] += 1
        print '.'
      end

      if @r.archival_objects
        if update_in_batches(@r.archival_objects)
          @response[:records_indexed][:archival_objects] += @r.archival_objects.length
        end
        puts
      end
    end
    puts "#{@response[:records_indexed][:resources]} resource,
      #{@response[:records_indexed][:archival_objects]} archival objects indexed"
    @response
  end


end
