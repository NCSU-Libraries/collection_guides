class ExecuteAspaceFullImport

  include GeneralUtilities

  def self.call(options={})
    object = new(options)
    object.call
  end

  def initialize(options)
    @options = options
  end

  def call
    execute_full_import
  end


  private


  def execute_full_import
    log_info "ExecuteAspaceFullImport called"
    @session = ArchivesSpaceApiUtility::ArchivesSpaceSession.new
    # @options[:update_start] ||= DateTime.now.to_formatted_s(:db)
    @page = @options[:page] || 1
    @last_page = nil
    @page_size = 10

    puts "Importing resources and resource trees..."

    @resources_updated = 0

    Repository.find_each do |repo|
      get_resources_for_repo(repo)
    end

    AspaceImport.create(import_type: 'full', resources_updated: @resources_updated)
    log_info "ExecuteAspaceFullImport complete"
  end


  def get_resources_for_repo(repo)
    path = "/repositories/#{repo.id}/resources"
    set_last_page(path)

    while @page <= @last_page
      get_page(path)
      @page += 1
    end
  end


  def set_last_page(path)
    # make initial request to get total pages:
    response = @session.get(path, page: @page, page_size: @page_size)

    if response.code.to_i == 200
      response = JSON.parse(response.body)
      @last_page ||= response['last_page']
    elsif response.code.to_i == 412
      log_info "Session lost - establishing new"
      @session = ArchivesSpaceApiUtility::ArchivesSpaceSession.new
      set_last_page(repo)
    end
  end


  def get_page(path)
    response = @session.get(path, page: @page, page_size: @page_size, resolve: ['linked_agents','subjects'])

    puts "Requesting page #{ @page } (#{ Time.now.to_s })"

    if response.code.to_i == 200
      response_data = JSON.parse(response.body)
      process_response(response_data)
    elsif response.code.to_i == 412
      log_info "Session lost - establishing new"
      @session = ArchivesSpaceApiUtility::ArchivesSpaceSession.new
      get_page(path)
    else
      raise response.body
    end

    message = "#{@resources_updated} resources updated so far."
    log_info message
  end


  def process_response(response_data)
    records = response_data['results']
    records.each do |r|
      # message = "#{r['uri']} - publish = #{r['publish']}, finding_aid_status = #{r['finding_aid_status'] || '[blank]'}"
      # log_info message

      if r['publish'] && r['finding_aid_status'] == "completed"
        @resources_updated += 1
        resource = Resource.create_or_update_from_data(r)
        UpdateResourceTree.call(resource.id)
      end
    end
  end

end
