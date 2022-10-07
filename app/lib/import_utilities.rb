module ImportUtilities

  include ArchivesSpaceApiUtility

  # valid record_type = resource, archival_object
  def get_records_from_archivesspace(record_type,options={})

    Repository.find_each do |repo|
      page = options[:page] || 1
      last_page = nil
      session = options[:session] || ArchivesSpaceSession.new

      puts "Importing #{record_type}..."

      case record_type
      when 'resource','resources'
        page_size = 10
        path_segment = 'resources'
        model = Resource
      when 'archival_object', 'archival_objects'
        page_size = 30
        path_segment = 'archival_objects'
        model = ArchivalObject
      end

      path = "/repositories/#{repo.id}/#{path_segment}"

      # make initial request to get total pages:
      response = session.get(path, page: page, page_size: page_size)
      if response.code.to_i == 200
        response = JSON.parse(response.body)
        last_page ||= response['last_page']
      end

      options = {
        page: page,
        page_size: page_size,
        path: path,
        model: model,
        session: session
      }
      while options[:page] <= last_page
        get_page_of_records(options)
        options[:page] += 1
      end

    end

    AspaceIndex.create

  end


  def get_page_of_records(options)
    session = options[:session] || ArchivesSpaceSession.new
    model = options[:model]

    response = session.get(options[:path], page: options[:page], page_size: options[:page_size], resolve: ['linked_agents','subjects'])

    puts "Requesting page #{options[:page]} (#{Time.now.to_s})"

    if response.code.to_i == 200
      response = JSON.parse(response.body)
      records = response['results']
      records.each do |r|
        exisiting_record = model.where(uri: r['uri']).first
        if exisiting_record
          puts "#{model.name} #{r['uri']} exists - updating..."
          exisiting_record.update_from_data(r)
        else
          puts "Creating #{model.name} #{r['uri']}..."
          model.create_from_data(r)
        end
      end
    else
      raise response.body
    end
  end


end
