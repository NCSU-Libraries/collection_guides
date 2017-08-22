require 'spec_helper'

DatabaseCleaner.start

describe Repository do
  
  $resource_response = $session.get(aspace_sample_paths[:resource])
  $resource_data = JSON.parse($resource_response.body)
  $repository_path = aspace_sample_paths[:repository]

  it "creates repository from api" do
    Repository.create_from_api($repository_path, $options)
    expect(Repository.where(uri: $repository_path)).to exist
  end

  it "raises an exception when trying to create a repository from an invalid path" do
    bad_path = aspace_sample_paths[:resource]
    expect(lambda { Repository.create_from_api(bad_path) }).to raise_error
  end

  it "updates repository from api" do
    Repository.create_from_api($repository_path, $options)
    r = Repository.find_by_uri($repository_path)
    old_name = r.name
    r.update_attribute(:name, 'TEST')
    r.reload
    expect(r.name).to eq('TEST')
    r.update_from_api($options)
    r.reload
    expect(r.name).to eq(old_name)
  end

end

DatabaseCleaner.clean
