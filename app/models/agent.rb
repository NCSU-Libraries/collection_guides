class Agent < ActiveRecord::Base

  include AspaceConnect

  attr_accessor :role, :relator, :relator_term, :relator_uri

  # NOTE: unlike resources, archival objects and subjects, the id attribute for agents
  #   does not necessarily correspond to ArchivesSpace ids (because AS defines 4 separate models for agents) - use URI as foreign key

  has_many :agent_associations
  has_many :records, through: :agent_associations

  @@uri_format = /^\/agents\/[\w]{6,}\/[\d]+$/

  def self.create_from_api(uri,options={})
    # validate uri format
    if !uri.match(@@uri_format)
      raise "URI is invalid"
    elsif self.exists?(uri: uri)
      raise "Agent already exists with uri '#{uri}'"
    else
      create_or_update_from_api(uri)
    end
  end


  def self.create_from_data(data,options={})
    d = prepare_data(data)
    r, json = d[:hash], d[:json]
    uri = r['uri']
    agent = self.new(uri: uri)
    agent.api_response = json
    agent.display_name = display_name_from_data(r)
    agent.agent_type = agent_type_from_uri(uri)
    agent.save
    agent
  end


  def update_from_data(data,options={})
    d = prepare_data(data)
    r, json = d[:hash], d[:json]
    attributes = {}
    attributes[:api_response] = json
    attributes[:display_name] = display_name_from_data(r)
    # no need to update agent_type because it's in the uri and a change will trigger creation of a new record
    update_attributes(attributes)
    reload
    self
  end


  def display_name_from_data(data=nil,options={})
    data ||= JSON.parse(api_response)
    Agent.display_name_from_data(data,options)
  end

  # Formulate a display form of the agent's name
  # Params:
  # +data+: ArchivesSpace agent object as a Ruby hash
  def self.display_name_from_data(data=nil,options={})
    if !data['names']
      raise "Data does not contain any names"
    else
      # first name is default if none are specified as display or authorized
      use_name = data['names'].first
      display_name = nil
      authorized_name = nil
      date = nil

      data['names'].each do |n|
        # use display name where present
        if n['is_display_name']
          display_name = n
          use_name = display_name
          break
        end
        if n['authorized']
          authorized_name = n
        end
      end

      if !display_name && authorized_name
        use_name = authorized_name
      end

      # Only use 'dates of existence', not 'use dates'
      if data['dates_of_existence']
        date = data['dates_of_existence'].first
      end

      # use sort_name, which is usually system-generated
      output = use_name['sort_name'].strip.gsub(/\,$/,'')

      if date

        if date['expression']
          date_string = date['expression']
        elsif date['begin'] || date['end']
          date_string = date['begin'] ? date['begin'].slice(0,4) : ''
          date_string << '-'
          date_string << date['end'] ? date['end'].slice(0,4) : ''
        end
        output += ", #{date_string}"
      end
    end
    output
  end


  # Load custom methods if they exist
  begin
    include AgentCustom
  rescue
  end

end
