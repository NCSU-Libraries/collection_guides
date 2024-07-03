class Repository < ApplicationRecord

  include GeneralUtilities
  include AspaceConnect

  self.primary_key = "id"

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
      update!(attributes)
    else
      raise response.body
    end
  end


  def citation
    repo_details = get_data_from_yaml('repository_details.yml')
    key = self.repo_code
    citation = repo_details[key]['citation']
    default = repo_details['default']['citation']
    citation || default
  end


end
