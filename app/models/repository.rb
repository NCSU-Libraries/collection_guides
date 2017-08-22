class Repository < ActiveRecord::Base

  include AspaceConnect

  validates :uri, uniqueness: true

  has_many :resources
  has_many :archival_objects
  has_many :digital_objects

  @@uri_format = /^\/repositories\/[\d]+$/

  def self.create_from_api(uri, options={})
    # validate uri format
    if !uri.match(@@uri_format)
      raise "URI is not in the form /repositores/:repo_id"
    else
      create_or_update_from_api(uri,options)
    end
  end


  def self.create_from_data(data, options={})
    d = prepare_data(data)
    r, json = d[:hash], d[:json]
    uri = r['uri']
    repository = new
    repository.id = repository_id_from_uri(uri)
    repository.uri = uri
    column_names.each do |c|
      if r[c]
        repository[c] = r[c]
      end
    end
    repository.save
  end


  def update_from_api(options={})
    session = options[:session] || ArchivesSpaceSession.new
    response = session.get(uri)
    if response.code.to_i == 200
      attributes = {}
      attributes[:api_response] = response.body
      r = JSON.parse(response.body)
      self.class.column_names.each do |c|
          if r[c]
            attributes[c.to_sym] = r[c]
          end
        end
      update_attributes(attributes)
    else
      raise response.body
    end
  end


  # Load custom methods if they exist
  begin
    include RepositoryCustom
  rescue
  end

end
