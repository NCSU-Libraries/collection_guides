require 'spec_helper'

describe DigitalObject, :type => :model do

  $digital_object_path = aspace_sample_paths[:digital_object]
  $digital_object_response = $session.get($digital_object_path, resolve: ['linked_agents','subjects'])
  $digital_object_data = JSON.parse($digital_object_response.body)

  it "creates digital object and linked subjects/agents from api" do
    DigitalObject.create_from_api($digital_object_path, $options)
    expect(DigitalObject.where(uri: $digital_object_path)).to exist
    d = DigitalObject.find_by_uri($digital_object_path)
    total_subjects = $digital_object_data['subjects'].length
    total_agents = $digital_object_data['linked_agents'].length
    expect(d.agents.length).to eq(total_agents)
    expect(d.subjects.length).to eq(total_subjects)
  end

  it "adds ArchivesSpace file_versions to unit-data as :files" do
    d = DigitalObject.create_from_api($digital_object_path, $options)
    data = d.presenter_data
    expect(data[:files].length).to eq($digital_object_data['file_versions'].length)
  end
end
