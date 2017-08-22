require 'spec_helper'

describe Agent do

  $agent_response = $session.get(aspace_sample_paths[:agent])
  $agent_data = JSON.parse($agent_response.body)

  it "creates agent from api with correct agent_type" do
    agent_path = aspace_sample_paths[:agent]
    Agent.create_from_api(agent_path, $options)
    expect(Agent.where(uri: agent_path)).to exist
    a = Agent.find_by_uri(agent_path)
    expect(a.agent_type).to eq('person')
  end

  it "raises an exception when trying to create a agent from an invalid path" do
    bad_path = aspace_sample_paths[:resource]
    expect(lambda { agent.create_from_api(bad_path) }).to raise_error
  end

  it "updates agent from api" do
    agent_path = aspace_sample_paths[:agent]
    Agent.create_from_api(agent_path, $options)
    a = Agent.find_by_uri(agent_path)
    old_name = a.display_name
    a.update_attribute(:display_name, 'TEST')
    a.reload
    expect(a.display_name).to eq('TEST')
    a.update_from_api($options)
    a.reload
    expect(a.display_name).to eq(old_name)
  end


  $agent_data1 = { "dates_of_existence"=>[{ "begin"=>"1885", "end"=>"1959", "date_type"=>"inclusive", "label"=>"existence" }],
    "names"=>[{ "primary_name"=>"Baumgarten", "rest_of_name"=>"William Ludwig", "sort_name"=>"Baumgarten, William Ludwig",
      "authorized"=>true, "is_display_name"=>true, "source"=>"local", "rules"=>"aacr", "name_order"=>"inverted", "use_dates"=>[]}],
      "uri"=>"/agents/people/30", "agent_type"=>"agent_person",
      "title"=>"Baumgarten, William Ludwig", "is_linked_to_published_record"=>true}

  $agent_data2 = { "dates_of_existence"=>[],
    "names"=>[{ "primary_name"=>"Baumgarten", "rest_of_name"=>"William Ludwig", "sort_name"=>"Baumgarten, William Ludwig",
      "authorized"=>true, "is_display_name"=>true, "source"=>"local", "rules"=>"aacr", "name_order"=>"inverted",
        "use_dates"=>[{ "begin"=>"1885", "end"=>"1959", "date_type"=>"inclusive", "label"=>"existence" }]}],
      "uri"=>"/agents/people/30", "agent_type"=>"agent_person",
      "title"=>"Baumgarten, William Ludwig", "is_linked_to_published_record"=>true}

  $agent_data3 = { "dates_of_existence"=>[{ "begin"=>"1885", "end"=>"1959", "date_type"=>"inclusive", "label"=>"existence" }],
    "names"=>[
      { "primary_name"=>"Baumgarten", "rest_of_name"=>"Jimmy", "sort_name"=>"Baumgarten, Jimmy",
      "authorized"=>true, "is_display_name"=>false, "source"=>"local", "rules"=>"aacr", "name_order"=>"inverted",
        "use_dates"=>[{ "begin"=>"1885", "end"=>"1959", "date_type"=>"inclusive", "label"=>"existence" }]},
      { "primary_name"=>"Baumgarten", "rest_of_name"=>"William Ludwig", "sort_name"=>"Baumgarten, William Ludwig",
      "authorized"=>true, "is_display_name"=>true, "source"=>"local", "rules"=>"aacr", "name_order"=>"inverted",
        "use_dates"=>[{ "begin"=>"1885", "end"=>"1959", "date_type"=>"inclusive", "label"=>"existence" }]}
    ],
    "uri"=>"/agents/people/30", "agent_type"=>"agent_person",
    "title"=>"Baumgarten, William Ludwig", "is_linked_to_published_record"=>true}


    it "generates display name with dates" do
      agent1 = create(:agent)
      agent1.api_response = JSON.generate($agent_data1)
      expect(agent1.display_name_from_data).to eq('Baumgarten, William Ludwig, 1885-1959')
      # should ignore use dates
      agent2 = create(:agent)
      agent2.api_response = JSON.generate($agent_data2)
      expect(agent2.display_name_from_data).to eq('Baumgarten, William Ludwig')
      # should prefer name defined as display name
      agent3 = create(:agent)
      agent3.api_response = JSON.generate($agent_data3)
      expect(agent3.display_name_from_data).to eq('Baumgarten, William Ludwig, 1885-1959')
    end

end
