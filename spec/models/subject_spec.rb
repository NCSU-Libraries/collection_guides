require 'spec_helper'

describe Subject do
  
  $subject_response = $session.get(aspace_sample_paths[:subject])
  $subject_data = JSON.parse($subject_response.body)

  it "creates subject from api" do
    subject_path = aspace_sample_paths[:subject]
    Subject.create_from_api(subject_path, $options)
    expect(Subject.where(uri: subject_path)).to exist
  end

  it "raises an exception when trying to create a subject from an invalid path" do
    bad_path = aspace_sample_paths[:resource]
    expect(lambda { Subject.create_from_api(bad_path) }).to raise_error
  end

  it "updates subject from api" do
    subject_path = aspace_sample_paths[:subject]
    Subject.create_from_api(subject_path, $options)
    s = Subject.find_by_uri(subject_path)
    old_subject = s.subject
    s.update_attribute(:subject, 'TEST')
    s.reload
    expect(s.subject).to eq('TEST')
    s.update_from_api($options)
    s.reload
    expect(s.subject).to eq(old_subject)
  end

end