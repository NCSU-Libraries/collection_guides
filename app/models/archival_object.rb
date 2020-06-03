class ArchivalObject < ApplicationRecord

  include AspaceConnect
  include ApiResponseData
  include SolrDoc
  include Associations
  include Presentation

  validates :uri, uniqueness: true

  belongs_to :repository
  belongs_to :resource
  belongs_to :parent, class_name: 'ArchivalObject', foreign_key: 'parent_id'
  has_many :agent_associations, -> { order('position ASC') }, as: :record, dependent: :destroy
  # has_many :agents, through: :agent_associations
  has_many :subject_associations, -> { order('position ASC') }, as: :record, dependent: :destroy
  has_many :subjects, through: :subject_associations
  has_many :digital_object_associations, -> { order('position ASC') }, as: :record, dependent: :destroy
  has_many :digital_objects, -> { where publish: true }, through: :digital_object_associations
  has_many :children, -> { order('position ASC') }, class_name: 'ArchivalObject', foreign_key: 'parent_id'

  @@uri_format = /^\/repositories\/[\d]+\/archival\_objects\/[\d]+$/


  # Class methods

  def self.create_from_api(uri, options={})
    # validate uri format
    if !uri.match(@@uri_format)
      raise "URI is not in the form /repositores/:repo_id/archival\_objects/:archival_object_id"
    else
      create_or_update_from_api(uri,options)
    end
  end


  def self.create_from_data(data, options={})
    d = prepare_data(data)
    r, json = d[:hash], d[:json]
    uri = r['uri']
    if uri
      archival_object = new
      archival_object.id = archival_object_id_from_uri(uri)
      archival_object.uri = uri
      archival_object.repository_id = repository_id_from_uri(uri)
      archival_object.api_response = json
      ['title','publish','position','level','component_id'].each { |x| archival_object[x] = r[x] }
      if r['resource']
        resource_uri = r['resource']['ref']
        archival_object.resource_id = resource_id_from_uri(resource_uri)
      end
      if r['parent']
        parent_uri = r['parent']['ref']
        archival_object.parent_id = archival_object_id_from_uri(parent_uri)
      end
      archival_object.save
      # add/update agents and associations
      archival_object.update_associated_agents_from_data(r['linked_agents'])
      # add/update agents and associations
      archival_object.update_associated_subjects_from_data(r['subjects'])
      archival_object.update_associated_digital_objects_from_data(r['instances'])
      archival_object.reload
    end
  end


  def self.update_from_api(options={})
    find_each { |ao| ao.update_from_api(options) }
    update_has_children
  end


  def self.update_has_children
    puts "Updating has_children attribute for ArchivalObject records..."
    find_each { |ao| ao.update_has_children }
  end


  # Delete archival objects for which the associated resource no longer exists
  def self.delete_orphans
    puts "Deleting orphaned ArchivalObject records..."
    orphan_query = "SELECT a.* FROM archival_objects a WHERE NOT EXISTS (SELECT id FROM resources WHERE id = a.resource_id)"
    orphans = ArchivalObject.find_by_sql(orphan_query)
    orphans.each { |o| o.destroy }
  end


# Update methods

  def update_from_data(data, options={})
    d = prepare_data(data)
    r, json = d[:hash], d[:json]
    attributes = {}
    attributes[:api_response] = json
    ['title','publish','position','level','uri','component_id'].each { |x| attributes[x.to_sym] = r[x] }
    if r['resource']
      resource_uri = r['resource']['ref']
      attributes[:resource_id] = resource_id_from_uri(resource_uri)
    end
    if r['parent']
      parent_uri = r['parent']['ref']
      attributes[:parent_id] = archival_object_id_from_uri(parent_uri)
    end
    update_attributes(attributes)
    # add/update agents and associations
    update_associated_agents_from_data(r['linked_agents'],options)
    # add/update agents and associations
    update_associated_subjects_from_data(r['subjects'],options)
    update_associated_digital_objects_from_data(r['instances'],options)
    reload
    update_unit_data
  end


  # Get methods


  def presenter
    p = Presenter.new(self)
  end


  def ancestors
    ancestor_list = []
    add_parent = Proc.new do |archival_object|
      p = archival_object.parent
      if p
        ancestor_list << p
        add_parent.call(p)
      end
    end
    add_parent.call(self)
    ancestor_list.reverse
  end


  def tree(options={})
    archival_object_tree = { title: title, id: id, node_type: 'archival_object', publish: publish, children: []}

    # Proc version 1 - does not include api_response, approx 2x faster and much smaller payload
    add_children = Proc.new do |parent, parent_id|
      pluck_columns = [:id, :title, :uri, :level, :position, :publish, :has_children]
      children_values = ArchivalObject.where(parent_id: parent_id).pluck(*pluck_columns)
      children_values.each do |c|
        child = {'node_type' => 'archival_object'}
        c.each_index { |i| child[pluck_columns[i].to_s] = c[i]}
        if child['has_children']
          add_children.call(child, child['id'])
        end
        (parent['children'] ||= []) << child
      end
    end

    # Proc version 2 - includes all attributes
    add_children_full = Proc.new do |parent, parent_id|
      ArchivalObject.where(parent_id: parent_id).each do |c|
        child = c.attributes.symbolize_keys
        if child['has_children']
          add_children_full.call(child, child['id'])
        end
        (parent['children'] ||= []) << child
      end
    end

    if options[:full]
      add_children_full.call(resource_tree, nil)
    else
      add_children.call(resource_tree, nil)
    end

    resource_tree
  end


  # Only returns id for each element in tree - 5x faster than tree
  def id_tree
    component_tree = { node_type: 'archival_object', id: id, children: [] }
    add_children = Proc.new do |parent, parent_id|
      children = ArchivalObject.where(parent_id: parent_id, resource_id: resource_id).order(:position).pluck(:id, :level)
      children.each do |c|
        child = {node_type: 'archival_object', id: c[0], level: c[1] }
        add_children.call(child, child[:id])
        (parent[:children] ||= []) << child
      end
    end
    add_children.call(component_tree, nil)
    component_tree
  end


  def get_aspace_solr_record
    q = "id:\"#{ uri }\""
    response = solr_get(q)
    response['response']['docs'][0]
  end


  # Load custom methods if they exist
  begin
    include ArchivalObjectCustom
  rescue
  end

end
