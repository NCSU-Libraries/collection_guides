require 'spec_helper'

DatabaseCleaner.start

describe ArchivalObject do
  
  $archival_object_path = aspace_sample_paths[:archival_object]
  $archival_object_response = $session.get($archival_object_path, resolve: ['linked_agents','subjects'])
  $archival_object_data = JSON.parse($archival_object_response.body)

  it "creates archival object and linked subjects/agents from api" do
    ArchivalObject.create_from_api($archival_object_path, $options)
    expect(ArchivalObject.where(uri: $archival_object_path)).to exist
    a = ArchivalObject.find_by_uri($archival_object_path)
    total_subjects = $archival_object_data['subjects'].length
    total_agents = $archival_object_data['linked_agents'].length
    expect(a.agents.length).to eq(total_agents)
    expect(a.subjects.length).to eq(total_subjects)
  end

  it "raises an exception when trying to create an archival_object from an invalid path" do
    bad_path = aspace_sample_paths[:resource]
    expect(lambda { ArchivalObject.create_from_api(bad_path) }).to raise_error
  end

  it "updates archival object from api" do
    ArchivalObject.create_from_api($archival_object_path, $options)
    a = ArchivalObject.find_by_uri($archival_object_path)
    old_title = a.title
    a.update_attribute(:title, 'TEST')
    a.reload
    expect(a.title).to eq('TEST')
    a.update_from_api($options)
    a.reload
    expect(a.title).to eq(old_title)
  end

end

DatabaseCleaner.clean
