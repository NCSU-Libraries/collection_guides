FactoryBot.define do


  factory :digital_object_volume do

  end

  factory :resource do
    sequence( :title ) { |n| "Test resource #{n}" }
    sequence( :id ) { |n| 10000 + n  }
    sequence( :uri ) { |n| "/repositories/2/resources/#{ 10000 + n }" }
    repository_id 2
    api_response { test_response(:resource) }
  end

  factory :archival_object do
    sequence( :title ) { |n| "Archival Object #{n}" }
    sequence( :id ) { |n| 10000 + n  }
    sequence( :uri ) { |n| "/repositories/2/archival_objects/#{ 10000 + n }" }
    sequence(:position) { |n| n }
    repository_id 2
    api_response { test_response(:archival_object) }
  end

  factory :agent do
    sequence( :display_name ) { |n| "Agent #{n}" }
    sequence( :uri ) { |n| "/agents/people/#{ 10000 + n }" }
    agent_type 'person'
  end

  factory :subject do
    sequence( :subject ) { |n| "Subject #{n}" }
    sequence( :id ) { |n| 10000 + n  }
    sequence( :uri ) { |n| "/subjects/#{ 10000 + n }" }
  end

  factory :agent_association do
  end

  factory :subject_association do
  end

end
