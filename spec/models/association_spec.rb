require 'spec_helper'

DatabaseCleaner.start

describe Associations do
  
  $resource_path = aspace_sample_paths[:resource]
  $resource_response = $session.get($resource_path, resolve: ['linked_agents','subjects'])
  $resource_data = JSON.parse($resource_response.body)

  it "associates a typed record with an agent" do
    r = Resource.create_from_api($resource_path, $options)
    a = r.agent_associations.first
    expect(a.record_type).to eq('Resource')
    expect(a.record_id).to eq(r.id)
    expect(a.agent).to be_a_kind_of(Agent)
    expect(a.record.id).to eq(r.id)
  end


  it "provides list of primary agents" do
    r = create(:resource, :api_response => JSON.generate(test_response_data[:resource]) )
    agents = create_list(:agent,3)
    roles = ['creator','subject','subject']
    agents.each_index do |i|
      agent = agents[i]
      create(:agent_association, :agent_id => agent.id, :record_id => r.id, :record_type => 'Resource', :role => roles[i])
    end
    r.reload
    expected = { 'creator' => [agents[0]], 'subject' => [agents[1], agents[2]] }
    expect(r.get_agents_by_role).to eq(expected)
  end


  it "provides primary agent(s) for resource" do
    r = create(:resource, :api_response => JSON.generate(test_response_data[:resource]) )
    agents = create_list(:agent,3)
    roles = ['creator','subject','subject']
    agents.each_index do |i|
      agent = agents[i]
      create(:agent_association, :agent_id => agent.id, :record_id => r.id, :record_type => 'Resource', :role => roles[i])
    end
    r.reload
    expected = [agents[0].display_name]
    expect(r.get_primary_agent_list).to eq([agents[0].display_name])
  end

end

DatabaseCleaner.clean