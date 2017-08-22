require 'spec_helper'

describe SearchIndex do


  it "adds resource records to Solr Index" do
    resources = create_list(:resource, 5)
    s = SearchIndex.new
    expect( lambda { s.execute_full }).not_to raise_error
    expect(s.records_updated).to eq(5)
    expect(s.index_type).to eq('full')
  end


  it "removes all records from the index" do
    expect( lambda { SearchIndex.wipe_index }).not_to raise_error
    SearchIndex.wipe_index 
    expect(SearchIndex.total_in_index).to eq(0)
  end


  it "gets total records in index" do
    SearchIndex.wipe_index
    resources = create_list(:resource, 5)
    s = SearchIndex.new
    s.execute_full
    expect(SearchIndex.total_in_index).to eq(5)
  end
  

  it "updates records that have changed since last index" do
    SearchIndex.wipe_index
    resources = create_list(:resource, 5)
    s = SearchIndex.new
    s.execute_full
    expect(SearchIndex.total_in_index).to eq(5)
    sleep 1
    3.times do |i|
      resources[i].update_attribute(:title, "New title #{i}")
    end
    s = SearchIndex.new
    expect( lambda { s.execute_delta }).not_to raise_error
    expect(s.records_updated).to eq(3)
    expect(s.index_type).to eq('delta')
    expect(SearchIndex.total_in_index).to eq(5)
  end


  it "adds archival_object records to Solr index" do
    resource = create(:resource)
    $archival_objects = create_list(:archival_object, 3, :resource_id => resource.id)
    s = SearchIndex.new
    s.execute_delta
    expect(s.records_updated).to eq(4)
  end
  

  it "removes all records from the index" do
    SearchIndex.wipe_index
    resources = create_list(:resource, 5)
    s = SearchIndex.new
    s.execute_full
    expect(SearchIndex.total_in_index).to eq(5)
    expect( lambda { SearchIndex.wipe_index }).not_to raise_error
    SearchIndex.wipe_index
    expect(SearchIndex.total_in_index).to eq(0)
  end


  it "performs full index with cleaning" do
    resources = create_list(:resource, 5)
    s = SearchIndex.new
    expect( lambda { s.execute_full(clean: true) }).not_to raise_error
    expect(s.records_updated).to eq(5)
    expect(s.index_type).to eq('full_clean')
  end

end

