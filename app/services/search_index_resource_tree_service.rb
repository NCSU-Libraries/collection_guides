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
      puts "Indexing tree for Resource #{@options[:resource_id]}..."

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

    resource_count = @response[:records_indexed][:resources]
    ao_count = @response[:records_indexed][:archival_objects]
    puts "indexed resources: #{resource_count}, indexed archival objects: #{ao_count}"
    @response
  end


end
