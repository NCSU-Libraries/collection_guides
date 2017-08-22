class Subject < ActiveRecord::Base

  include AspaceConnect

  has_many :subject_associations
  has_many :records, through: :subject_associations

  @@uri_format = /^\/subjects\/[\d]+$/

  def self.create_from_api(uri,options={})
    # validate uri format
    if !uri.match(@@uri_format)
      raise "URI is invalid"
    elsif self.exists?(uri: uri)
      raise "Subject already exists with uri '#{uri}'"
    else
      create_or_update_from_api(uri)
    end
  end


  def self.create_from_data(data,options={})
    d = prepare_data(data)
    r, json = d[:hash], d[:json]
    uri = r['uri']
    subject = self.new(uri: uri)
    subject.id = subject_id_from_uri(uri)
    subject.api_response = json
    subject.subject = r['title']
    subject.subject_type = r['terms'].first['term_type']
    subject.save
    subject
  end


  def update_from_data(data,options={})
    d = prepare_data(data)
    r, json = d[:hash], d[:json]
    attributes = {}
    attributes[:api_response] = json
    attributes[:subject] = r['title']
    attributes[:subject_type] = r['terms'].first['term_type']
    # no need to update id or uri because change will trigger creation of a new record
    update_attributes(attributes)
    self
  end


  # Load custom methods if they exist
  begin
    include SubjectCustom
  rescue
  end


end
