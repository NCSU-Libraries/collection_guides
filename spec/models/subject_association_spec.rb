require 'spec_helper'

DatabaseCleaner.start

describe SubjectAssociation do
  
  $resource_path = aspace_sample_paths[:resource]
  $resource_response = $session.get($resource_path, resolve: ['linked_agents','subjects'])
  $resource_data = JSON.parse($resource_response.body)

  it "associates a typed record with an subject" do
    r = Resource.create_from_api($resource_path, $options)
    a = r.subject_associations.first
    expect(a.record_type).to eq('Resource')
    expect(a.record_id).to eq(r.id)
    expect(a.subject).to be_a_kind_of(Subject)
    expect(a.record.id).to eq(r.id)
  end

end

DatabaseCleaner.clean