class Resource < ApplicationRecord

  include AspaceConnect
  include ApiResponseData
  include SolrDoc
  include Associations
  include Presentation
  include GeneralUtilities

  self.primary_key = "id"

  validates :uri, uniqueness: true


  belongs_to :repository
  has_many :archival_objects

  has_many :agent_associations, -> { order('position ASC') }, as: :record, dependent: :destroy
  # has_many :agents, through: :agent_associations

  has_many :subject_associations, -> { order('position ASC') }, as: :record, dependent: :destroy
  has_many :subjects, through: :subject_associations

  has_many :digital_object_associations, -> { order('position ASC') }, as: :record, dependent: :destroy
  has_many :digital_objects, through: :digital_object_associations
  has_many :children, -> { where('parent_id IS NULL').order('position ASC') }, class_name: 'ArchivalObject'


  @@uri_format = /^\/repositories\/[\d]+\/resources\/[\d]+$/


  def self.create_from_api(uri, options={})
    # validate uri format
    if !uri.match(@@uri_format)
      raise "URI is not in the form /repositores/:repo_id/resources/:resource_id"
    else
      create_or_update_from_api(uri,options)
    end
  end


  def self.update_hierarchy_attributes(options={})
    start = options[:start] || 1
    find_each(start: start) { |r| r.update_hierarchy_attributes; print '.' }
  end


  def self.create_from_data(data, options={})
    d = prepare_data(data)
    r, json = d[:hash], d[:json]
    uri = r['uri']
    resource = new
    resource.id = resource_id_from_uri(uri)
    resource.uri = uri
    resource.repository_id = repository_id_from_uri(uri)
    resource.api_response = json
    resource.title = r['title']
    resource.publish = r['publish']
    resource.eadid = slugify(r['id_0'])
    resource.save
    # add/update agents and associations
    resource.update_associated_agents_from_data(r['linked_agents'])
    # add/update agents and associations
    resource.update_associated_subjects_from_data(r['subjects'])
    resource.update_associated_digital_objects_from_data(r['instances'])
    resource.reload
  end


  def self.update_from_api(options={})
    find_each { |r| r.update_from_api(options) }
  end


  def self.update_load_position
    find_each { |r| r.update_load_position }
  end


  def update_from_data(data, options={})
    d = prepare_data(data)
    r, json = d[:hash], d[:json]
    attributes = {}
    attributes[:api_response] = json
    attributes[:eadid] = r['ead_id'] ? slugify(r['ead_id']) : slugify(r['id_0'])
    ['title','publish','uri'].each { |x| attributes[x.to_sym] = r[x] }
    update_attributes(attributes)
    # add/update agents and associations
    update_associated_agents_from_data(r['linked_agents'],options)
    # add/update agents and associations
    update_associated_subjects_from_data(r['subjects'],options)
    update_associated_digital_objects_from_data(r['instances'],options)
    reload
    update_unit_data
  end


  def update_tree_unit_data
    update_unit_data
    archival_objects.find_each { |a| a.update_unit_data }
    reload
    update_hierarchy_attributes
  end


  def update_structure
    update_column(:structure, JSON.generate(id_tree))
  end


  def update_total_components
    update_column(:total_components, archival_objects.count)
  end


  def top_components
    archival_objects.where(parent_id: nil)
  end


  def update_total_top_components
    top_count = archival_objects.where(parent_id: nil).count
    update_column(:total_top_components, top_count)
  end


  # Updates load_position value for all descendants
  def update_load_position
    seq = 0
    update_children = Proc.new do |parent_id|
      children = ArchivalObject.where(parent_id: parent_id, resource_id: id).order(:position)
      children.each do |c|
        c.update_column(:load_position, seq)
        seq += 1
        if c.has_children
          update_children.call(c.id)
        end
      end
    end
    update_children.call(nil)
  end


  def update_hierarchy_attributes
    update_structure
    update_total_components
    update_total_top_components
    update_has_children
    reload
    if has_children
      archival_objects.find_each { |a| a.update_has_children }
      reload
      update_load_position
    end
  end


  # Only returns id for each element in tree - 5x faster than tree
  def id_tree
    resource_tree = { node_type: 'resource', id: id, children: [] }
    add_children = Proc.new do |parent, parent_id|
      children = ArchivalObject.where(parent_id: parent_id, resource_id: id).order(:position).pluck(:id, :level)
      children.each do |c|
        child = {node_type: 'archival_object', id: c[0], level: c[1] }
        add_children.call(child, child[:id])
        (parent[:children] ||= []) << child
      end
    end
    add_children.call(resource_tree, nil)
    resource_tree
  end


  def tree(options={})
    resource_tree = { title: title, id: id, node_type: 'resource', publish: publish, children: []}

    # Proc version 1 - does not include api_response, approx 2x faster and much smaller payload
    add_children = Proc.new do |parent, parent_id|
      pluck_columns = [:id, :title, :uri, :level, :position, :publish, :has_children]
      children_values = ArchivalObject.where(parent_id: parent_id, resource_id: id).order(:position).pluck(*pluck_columns)
      parent[:children] = []
      children_values.each do |c|
        child = {:node_type => 'archival_object'}
        c.each_index { |i| child[pluck_columns[i]] = c[i]}
        add_children.call(child, child[:id], options)
        parent[:children] << child
      end
    end

    # Proc version 2 - includes all attributes
    add_children_full = Proc.new do |parent, parent_id|
      ArchivalObject.where(parent_id: parent_id, resource_id: id).order(:position).each do |c|
        child = c.attributes
        child.symbolize_keys!
        if child[:has_children]
          if options[:full]
            add_children_full.call(child, child[:id])
          else
            add_children.call(child, child[:id])
          end
        end
        (parent[:children] ||= []) << child
      end
    end

    if options[:full] || options[:top_full]
      add_children_full.call(resource_tree, nil)
    else
      add_children.call(resource_tree, nil)
    end

    resource_tree
  end


  def presenter
    Presenter.new(self)
  end


  def has_descendant_digital_objects
    descendant_digital_objects.length > 0
  end


  def has_descendant_digital_objects_with_files
    descendant_digital_objects_with_files.length > 0
  end


  # returns
  def descendant_digital_objects_with_files
    sql = "SELECT do.* from digital_objects do
      JOIN digital_object_associations doa ON do.id = doa.digital_object_id
      JOIN archival_objects a ON a.id = doa.record_id
      WHERE doa.record_type = 'ArchivalObject'
      AND a.resource_id = #{id}
      AND do.publish = 1
      AND do.has_files = 1"
    DigitalObject.find_by_sql(sql)
  end


  def descendant_digital_objects
    sql = "SELECT do.* from digital_objects do
      JOIN digital_object_associations doa ON do.id = doa.digital_object_id
      JOIN archival_objects a ON a.id = doa.record_id
      WHERE doa.record_type = 'ArchivalObject'
      AND a.resource_id = #{id}
      AND do.publish = 1"
    DigitalObject.find_by_sql(sql)
  end


  def series
    archival_objects.where(parent_id: nil, resource_id: id, level: 'series')
  end


  # Load custom methods if they exist
  begin
    include ResourceCustom
  rescue
  end

end
