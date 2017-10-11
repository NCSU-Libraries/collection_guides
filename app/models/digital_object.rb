class DigitalObject < ActiveRecord::Base

  include AspaceConnect
  include SolrDoc
  include Associations
  include Presentation

  validates :uri, uniqueness: true

  belongs_to :repository
  has_many :digital_object_associations

  has_many :resources, through: :digital_object_associations, source: :record, source_type: 'Resource'
  has_many :archival_objects, through: :digital_object_associations, source: :record, source_type: 'ArchivalObject'

  has_many :digital_object_volumes, -> { order('position ASC') }, dependent: :destroy

  has_many :agent_associations, -> { order('position ASC') }, as: :record, dependent: :destroy
  # has_many :agents, through: :agent_associations
  has_many :subject_associations, -> { order('position ASC') }, as: :record, dependent: :destroy
  has_many :subjects, through: :subject_associations

  after_save :update_has_files

  @@uri_format = /^\/repositories\/[\d]+\/digital\_objects\/[\d]+$/

  def self.create_from_api(uri, options={})
    # validate uri format
    if !uri.match(@@uri_format)
      raise "URI is not in the form /repositores/:repo_id/digital\_objects/:digital_object_id"
    else
      create_or_update_from_api(uri,options)
    end
  end


  def self.create_from_data(data,options={})
    d = prepare_data(data)
    r, json = d[:hash], d[:json]
    uri = r['uri']
    if uri
      digital_object = new
      digital_object.id = digital_object_id_from_uri(uri)
      digital_object.uri = uri
      digital_object.repository_id = repository_id_from_uri(uri)
      digital_object.api_response = json
      ['title','publish','digital_object_id'].each { |x| digital_object[x] = r[x] }
      digital_object.save
      # add/update agents and associations
      digital_object.update_associated_agents_from_data(r['linked_agents'])
      # add/update agents and associations
      digital_object.update_associated_subjects_from_data(r['subjects'])
    end
  end


  def update_from_data(data,options={})
    d = prepare_data(data)
    r, json = d[:hash], d[:json]
    attributes = {}
    attributes[:api_response] = json
    ['title','publish','digital_object_id'].each { |x| attributes[x.to_sym] = r[x] }
    update_attributes(attributes)
    # add/update agents and associations
    update_associated_agents_from_data(r['linked_agents'])
    # add/update agents and associations
    update_associated_subjects_from_data(r['subjects'])
    reload
    self
  end


  def presenter_data
    do_data = {}
    [:id, :uri, :title, :digital_object_id, :publish, :show_thumbnails].each do |attr|
      do_data[attr] = self[attr]
    end

    do_response_data = JSON.parse(api_response)

    if do_response_data['file_versions']
      do_response_data['file_versions'].each do |f|
        remove_keys = ["lock_version", "created_by", "last_modified_by",
          "create_time", "system_mtime", "user_mtime", "jsonmodel_type"]
        remove_keys.each do |k|
          f.delete(k)
        end
        (do_data[:files] ||= []) << f
      end
    end

    if !digital_object_volumes.blank?
      do_data[:digital_object_volumes] = []
      digital_object_volumes.each do |v|
        # do_data[:digital_object_volumes] << { filesystem_browse_url: v.filesystem_browse_url }
        do_data[:digital_object_volumes] << { volume_id: v.volume_id }
      end
    end

    do_data
  end


  def has_files?
    has_files
  end


  def update_has_files
    if !api_response.blank?
      data = JSON.parse(api_response)
      value = data['file_versions'] &&
          !data['file_versions'].empty? ?
              true : false
      update_attributes(has_files: value)
    end
  end


  # Load custom methods if they exist
  begin
    include DigitalObjectCustom
  rescue
  end

end
