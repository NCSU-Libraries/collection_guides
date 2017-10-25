class SearchController < ApplicationController

  include SearchHelper

  def index
    @q = params[:q]

    ######################################################################
    # Process request params
    ######################################################################

    if params[:reset_filters]
      params[:filters] = {}
    else
      params[:filters] ||= {}
    end

    # remove filters with no value
    params[:filters].delete_if { |k,v| v.blank? }

    # convert values of '0' to false
    params.each do |k,v|
      if v == '0'
        params[k] = false
      end
    end

    # @filters only include facet values included in the request. Additional filters will be added to the query.
    @filters = !params[:filters].blank? ? params[:filters].clone : {}


    # process special filters (i.e. keys don't correspond to Solr fields)
    params[:filters][:agents] ||= []
    params[:filters].each do |k,v|
      case k
      when 'inclusive_years'
        # values are year ranges in the form YYYY-YYYY
        ranges = []
        v.each do |range|
          dates = range.split('-').map { |x| x.to_i }
          ranges << "[#{dates[0]} TO #{dates[1]}]"
        end
        params[:filters][:inclusive_years] = ranges
      when 'ncsu_subjects'
        # These are subdivided corporate name subjects, so they are recorded as agents
        v.each do |subject|
          params[:filters][:agents] << subject
        end
      end
    end
    params[:filters].delete('ncsu_subjects')




    # define base href used for pagination and filtering
    @base_href_options = {
      q: @q,
      filters: @filters.empty? ? nil : @filters.clone,
      per_page: params[:per_page] ? params[:per_page] : nil
    }

    # process special parameters for specific views
    if params[:resource_id]
      params[:filters]['record_type'] = 'archival_object'
      params[:filters]['resource_id'] = params[:resource_id]
      params[:group] = false
      @resource = Resource.find params[:resource_id]
      @base_href_options[:resource_id] = params[:resource_id]
    elsif params[:subject_id]
      params[:filters]['subjects_id'] = params[:subject_id]
      @subject = Subject.find params[:subject_id]
      @base_href_options[:subject_id] = params[:subject_id]
    elsif params[:agent_id]
      params[:filters]['agents_id'] = params[:agent_id]
      @agent = Agent.find params[:agent_id]
      @base_href_options[:agent_id] = params[:agent_id]
    elsif params[:all_resources]
      @all_resources = true
      @base_href_options[:all_resources] = true
      params[:filters]['record_type'] = 'resource'
    end

    puts @base_href_options.inspect

    @base_href = searches_path(@base_href_options)

    ######################################################################
    # Execute query
    ######################################################################

    s = Search.new(params)
    @response = s.execute

    # puts @response['grouped']['resource_uri']['groups'].length

    ######################################################################
    # Prepare response data for view
    ######################################################################

    # prepare facets
    process_facets(params)

    # custom facets
    process_custom_facets(params)


    # Prepare pagination variables
    set_pagination_vars(params)


    respond_to do |format|
      format.html
      format.json do
        if params[:simple_response]
          @response = simple_response
        end
        render :json => @response
      end
    end
  end


  private


    def set_pagination_vars(params)
      @per_page = params[:per_page] ? params[:per_page].to_i : 20

      if params[:resource_id]
        @total_components = @response['response']['numFound']
        @pages = (@total_components.to_f / @per_page.to_f).ceil
      else
        @total_collections = @response['facet_counts']['facet_fields']['resource_uri'].length / 2
        @pages = (@total_collections.to_f/@per_page.to_f).ceil
      end

      @page = params[:page] ? params[:page].to_i : 1

      if @page <= 6
        @page_list_start = 1
      elsif (@page > (@pages - 9)) && ((@pages - 9) > 10)
        @page_list_start = @pages - 9
      else
        @page_list_start = @page - 5
      end

      if (@pages < 10) || ((@page + 4) > @pages)
        @page_list_end = @pages
      else
        @page_list_end = @page_list_start + 9
      end
    end


    def process_facets(params)
      raw_facets = @response['facet_counts']['facet_fields']
      @facets = {}
      # Convert facet_counts array to hash
      raw_facets.each do |f,v|
        if v.kind_of? Array
          @facets[f] = {}
          i = 0
          until i >= raw_facets[f].length
            value = raw_facets[f][i]
            count = raw_facets[f][i + 1]
            @facets[f][value] = count
            i += 2
          end
        else
          @facets[f] = v
        end
      end
      # Sort select facets by count
      facets_to_sort = ['agents']
      facets_to_sort.each do |f|
        sorted = @facets[f].sort_by { |k,v| v }
        sorted.reverse!
        sorted_hash = {}
        sorted.each { |x| sorted_hash[x[0]] = x[1] }
        @facets[f] = sorted_hash
      end
      @facets
    end


    # Included here so that it can be overridden in SearchControllerCustom
    def process_custom_facets(params)
      @facets
    end


  public


  # Load custom methods if they exist
  begin
    include SearchControllerCustom
  rescue
  end


end
