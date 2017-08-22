require 'spec_helper'


describe SolrDoc do

  it "generates a hash of values for a resource" do
    r = create(:resource, :api_response => JSON.generate(test_response_data[:resource]) )
    d = r.solr_doc_data
    expect(d).to be_a_kind_of(Hash)
  end

  it "records values for record attributes" do
    r = create(:resource, :api_response => JSON.generate(test_response_data[:resource]) )
    d = r.solr_doc_data
    expect(d[:title]).to eq(r.title)
    expect(d[:record_type]).to eq('resource')
    expect(d[:record_id]).to eq(r.id)
    expect(d[:uri]).to eq(r.uri)
  end


  it "records note text" do
    r = create(:resource, :api_response => JSON.generate(test_response_data[:resource]) )
    d = r.solr_doc_data

    notes_expected_hash = parse_mixed_notes_expected.clone

    notes_expected_hash.delete('abstract')
    notes_expected = []
    notes_expected_hash.each do |k,v|
      v.each { |note| notes_expected << note['content'] }
    end
    expect(d[:notes]).to eq(notes_expected)
  end


  it "records abstract, date statement, extent statement, collection id" do
    r = create(:resource, :api_response => JSON.generate(test_response_data[:resource]) )
    d = r.solr_doc_data
    expect(d[:abstract]).to eq("This is the abstract!")
    expect(d[:date_statement]).to eq(date_statement_expected)
    expect(d[:extent_statement]).to eq(mixed_extent_expected)
    expect(d[:collection_id]).to eq("TEST1234")
  end


  it "records primary agents for resource" do
    r = create(:resource, :api_response => JSON.generate(test_response_data[:resource]) )
    agents = create_list(:agent,3)
    roles = ['creator','subject','subject']
    agents.each_index do |i|
      agent = agents[i]
      create(:agent_association, :agent_id => agent.id, :record_id => r.id, :record_type => 'Resource', :role => roles[i])
    end
    r.reload
    r.update_unit_data

    d = r.solr_doc_data

    expect(d[:primary_agent]).to eq([agents[0].display_name])
  end


  it "records all linked agents and uris" do
    r = create(:resource, :api_response => JSON.generate(test_response_data[:resource]) )
    agents = create_list(:agent,3)
    roles = ['creator','subject','subject']
    agents.each_index do |i|
      agent = agents[i]
      create(:agent_association, :agent_id => agent.id, :record_id => r.id, :record_type => 'Resource', :role => roles[i])
    end
    r.reload
    d = r.solr_doc_data
    expect(d[:agents]).to eq(agents.map { |a| a.display_name })
    expect(d[:agents_uri]).to eq(agents.map { |a| a.uri })
  end



  it "records all subjects and uris" do
    r = create(:resource, :api_response => JSON.generate(test_response_data[:resource]) )
    subjects = create_list(:subject,3)
    subjects.each do |s|
      create(:subject_association, :subject_id => s.id, :record_id => r.id, :record_type => 'Resource')
    end
    r.reload
    d = r.solr_doc_data
    expect(d[:subjects]).to eq(subjects.map { |a| a.subject })
    expect(d[:subjects_uri]).to eq(subjects.map { |s| s.uri })
  end




  it "generates a hash of values for an archival object" do
    r = create(:resource, :api_response => JSON.generate(test_response_data[:resource]) )
    a = create(:archival_object, :resource_id => r.id, :parent_id => nil, :position => 0)
    ad = a.solr_doc_data
    expect(ad).to be_a_kind_of(Hash)
  end

  it "records resource attributes with an archival object or resource" do
    r = create(:resource, :api_response => JSON.generate(test_response_data[:resource]) )
    agents = create_list(:agent,3)
    roles = ['creator','subject','subject']
    agents.each_index do |i|
      agent = agents[i]
      create(:agent_association, :agent_id => agent.id, :record_id => r.id, :record_type => 'Resource', :role => roles[i])
    end
    r.reload
    r.update_unit_data
    d = r.solr_doc_data
    a = create(:archival_object, :resource_id => r.id, :parent_id => nil, :position => 0)
    ad = a.solr_doc_data
    expect(ad[:resource_uri]).to eq(r.uri)
    expect(ad[:resource_title]).to eq(r.title)
    expect(ad[:resource_collection_id]).to eq("TEST1234")
    expect(ad[:resource_abstract]).to eq("This is the abstract!")
    expect(ad[:resource_primary_agent]).to eq([agents[0].display_name])
    expect(ad[:resource_date_statement]).to eq(date_statement_expected)
    expect(ad[:resource_extent_statement]).to eq(mixed_extent_expected)
    expect(d[:resource_uri]).to eq(r.uri)
    expect(d[:resource_title]).to eq(r.title)
    expect(d[:resource_collection_id]).to eq("TEST1234")
    expect(d[:resource_abstract]).to eq("This is the abstract!")
    expect(d[:resource_primary_agent]).to eq([agents[0].display_name])
    expect(d[:resource_date_statement]).to eq(date_statement_expected)
    expect(d[:resource_extent_statement]).to eq(mixed_extent_expected)
  end



end
