require 'spec_helper'

describe Resource do

  $resource_path = aspace_sample_paths[:resource]
  $resource_response = $session.get($resource_path, resolve: ['linked_agents','subjects'])
  $resource_data = JSON.parse($resource_response.body)

  it "creates resource and linked subjects/agents from api" do
    Resource.create_from_api($resource_path, $options)
    expect(Resource.where(uri: $resource_path)).to exist
    r = Resource.find_by_uri($resource_path)
    total_subjects = $resource_data['subjects'].length
    total_agents = $resource_data['linked_agents'].length
    expect(r.agent_associations.length).to eq(total_agents)
    expect(r.subject_associations.length).to eq(total_subjects)
  end

  it "raises an exception when trying to create a resource from an invalid path" do
    bad_path = aspace_sample_paths[:archival_object]
    expect(lambda { Resource.create_from_api(bad_path) }).to raise_error
  end

  it "creates subject associations with correct position" do
    Resource.create_from_api($resource_path, $options)
    r = Resource.find_by_uri($resource_path)
    expected_position = $resource_data['subjects'].length - 1
    test_subject_data = $resource_data['subjects'].last['_resolved']
    test_subject_uri = test_subject_data['uri']
    subject = Subject.find_by_uri(test_subject_uri)
    association = r.subject_associations.where(subject_id: subject.id).first
    expect(association.position).to eq(expected_position)
  end

  it "creates agent associations with correct position" do
    Resource.create_from_api($resource_path, $options)
    r = Resource.find_by_uri($resource_path)
    expected_position = $resource_data['linked_agents'].length - 1
    test_agent_data = $resource_data['linked_agents'].last['_resolved']
    test_agent_role = $resource_data['linked_agents'].last['role']
    test_agent_uri = test_agent_data['uri']
    agent = Agent.find_by_uri(test_agent_uri)
    association = r.agent_associations.where(agent_id: agent.id, role: test_agent_role).first
    expect(association.position).to eq(expected_position)
  end

  it "updates resource from api" do
    Resource.create_from_api($resource_path, $options)
    r = Resource.find_by_uri($resource_path)
    old_title = r.title
    r.update_attribute(:title, 'TEST')
    r.reload
    expect(r.title).to eq('TEST')
    r.update_from_api($options)
    r.reload
    expect(r.title).to eq(old_title)
  end

  it "creates descendant records from api" do
    Resource.create_from_api($resource_path, $options)
    resource_tree_path = "#{$resource_path}/tree"
    resource_tree_response = $session.get(resource_tree_path)
    resource_tree_data = JSON.parse(resource_tree_response.body)
    total_descendants = total_descendants_in_response(resource_tree_data)
    expect(total_descendants).to be_a_kind_of(Numeric)
    r = Resource.find_by_uri($resource_path)
    r.update_tree_from_api($options)
    r.reload
    expect(r.archival_objects.length).to eq(total_descendants)
  end

  it "generates tree of descendant archival_object records" do
    Resource.create_from_api($resource_path, $options)
    r = Resource.find_by_uri($resource_path)
    tree = r.tree
    expect(tree).to be_a_kind_of(Hash)
    expect(tree[:children].length).to eq(r.children.length)

    test_children = Proc.new do |child|
      child_record = ArchivalObject.find_by_uri(child[:uri])
      expect(child_record).to be_a_kind_of(ArchivalObject)
      expect(child[:children].length).to be_a_kind_of(Numeric)
      expect(child_record.children.length).to be_a_kind_of(Numeric)
      expect(child[:children].length).to eq(child_record.children.length)
      child[:children].each { |c| test_children.call(c) }
    end

    tree[:children].each { |child| test_children.call(child) }
  end

  # END tests requiring API calls - use factories from here


  it "generates a solr doc hash for the resource" do
    r = create(:resource)
    doc = r.solr_doc_data
    expect(doc).to be_a_kind_of(Hash)
    expect(doc[:title]).to eq (r.title)
    expect(doc[:record_type]).to eq ('resource')
  end


end
