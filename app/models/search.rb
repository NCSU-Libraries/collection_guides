class Search

  require 'solr_sanitizer'

  def initialize(options = {})
    @q = options[:q]
    @filters = !options[:filters].blank? ? options[:filters] : {}
    @page = options[:page] || 1
    @per_page = options[:per_page] ? options[:per_page].to_i : 20
    @simple = options[:simple] || nil
    @wt = :ruby
    @start = options[:start] || ((@page.to_i - 1) * @per_page)
    @sort = options[:sort]
    @group = options[:group] === false ? false : true
  end

  attr_accessor :q, :page, :per_page, :filters, :wt, :simple


  # Specify fields to be queried and boost values for each
  def set_query_fields
    @query_fields = {
     'eadid' => 1500,
     'identifier' => 1500,
     'resource_title' => 1500,
     'title_t' => 1500,
     'collection_id' => 1500,
     'resource_title_t' => 2500,
     'primary_agent_t' => 100,
     'subjects_t' => 300,
     'agents_t' => 50,
     'abstract' => nil,
     'notes' => nil,
     'agents' => nil,
     'subjects' => nil
    }
  end


  def set_solr_params
    @solr_params = { :wt => self.wt || :ruby }
    @solr_params[:start] = @start
    @solr_params[:rows] = self.per_page
    @solr_params[:sort] = @sort ? @sort : nil

    if !self.simple
      @solr_params[:defType] = 'edismax'
      @solr_params['q.alt'] = '*:*'

      # query string
      if !self.q.blank?
        @solr_params[:q] = self.q
      else
        @solr_params[:sort] ||= 'resource_title asc'
        @filters['record_type'] ||= 'resource'
      end

      # result grouping
      if @group
        @solr_params['group'] = true
        @solr_params['group.field'] = 'resource_uri'
        @solr_params['group.limit'] = 5
      end

      # highlighting
      # @solr_params['hl'] = true
      # @solr_params['hl.fl'] = ''
      # @solr_params['hl.simple.pre'] = "<mark>"
      # @solr_params['hl.simple.post'] = "</mark>"

      set_query_fields()
      custom_query_fields()

      puts @query_fields.inspect

      # Set qf using query_fields above
      @solr_params[:qf] = ''
      @query_fields.each do |k,v|
        @solr_params[:qf] += " #{k}"
        @solr_params[:qf] += v ? "^#{v}" : ''
      end
      @solr_params[:qf].strip!

      # facets
      @solr_params['facet'] = true
      @solr_params['facet.field'] = ['resource_uri','resource_digital_content','repository_name','resource_category','inclusive_years','agents']
      @solr_params['facet.limit'] = -1
      @solr_params['facet.mincount'] = 1

      # boost query
      @solr_params[:bq] = []

      # minimum match
      @solr_params[:mm] = '3<67%'

      # phrase fields/slop
      @solr_params[:pf] = @query_fields.keys
      @solr_params[:ps] = 3

    else
      @solr_params[:defType] = 'lucene'
      @solr_params[:q] = self.q
    end

    # process filters (selected facets)
    @fq = []

    if !@filters.blank?
      @filters.each do |k,v|
        if !v.blank?
          if k == 'collection_id' || v =~ /^\[.*\]$/
            @fq << "#{k}: #{SolrSanitizer.sanitize_integer(v)}" if !v.blank?
          # 'inclusive_years' is expected to be an array of strings
          elsif k == 'inclusive_years'
            if v.is_a? Array
              values = v.map { |vv| SolrSanitizer.sanitize_numeric_range(vv) }
              values.reject! { |vv| vv.nil? }
              @fq << "#{k}: (#{values.join(' ')})" if !values.blank?
            end
          else
            case v
            when String
              # value = SolrSanitizer.sanitize_query_string(v)
              value = RSolr.solr_escape(v)
              @fq << "#{k}: \"#{value}\""
            when Array
              v.uniq!
              v.each do |f|
                # value = SolrSanitizer.sanitize_query_string(f)
                value = RSolr.solr_escape(f)
                @fq << "#{k}: \"#{value}\""
              end
            end
          end
        end
      end
    end

    @solr_params['fq'] = @fq.uniq
    custom_solr_params()
    # puts @solr_params

    @solr_params
  end


  def custom_query_fields
    @query_fields['collection_id_split'] = nil
  end

  def custom_solr_params
    @solr_params[:bq] << "record_type:resource^800"
    if @q
      @solr_params[:bq] << "collection_id:\"#{@q.gsub(/\"/,'')}\"^1000000"
    end
  end


  def execute
    solr_url = "http://#{ENV['solr_host']}:#{ENV['solr_port']}#{ENV['solr_core_path']}"
    @solr = RSolr.connect :url => solr_url
    set_solr_params()

    Rails.logger.info "SOLR URL: #{solr_url}"
    Rails.logger.debug ENV.keys.inspect
    Rails.logger.debug("@solr_params : #{@solr_params}")

    @response = @solr.paginate self.page, self.per_page, "select", :params => @solr_params
  end


end
