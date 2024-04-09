FactoryBot.define do
  factory :resource_tree_update do
    
  end

  factory :repository do
    sequence( :id ) { |n| 2 + n  }
    sequence( :uri ) { |n| "/repositories/#{ 2 + n }" }
    sequence( :repo_code ) { |n| "repo#{n}"  }
    sequence( :name ) { |n| "repo#{n}"  }
  end

  factory :resource do
    sequence( :title ) { |n| "Test resource #{n}" }
    sequence( :id ) { |n| 10000 + n  }
    sequence( :uri ) { |n| "/repositories/2/resources/#{ 10000 + n }" }
    # repository_id { 2 }
    repository
    api_response { test_response(:resource) }
  end

  factory :agent do
    sequence( :display_name ) { |n| "Agent #{n}" }
    sequence( :uri ) { |n| "/agents/people/#{ 10000 + n }" }
    agent_type { 'person' }
  end

  factory :subject do
    sequence( :subject ) { |n| "Subject #{n}" }
    sequence( :id ) { |n| 10000 + n  }
    sequence( :uri ) { |n| "/subjects/#{ 10000 + n }" }
  end

  factory :archival_object do
    sequence( :title ) { |n| "Archival Object #{n}" }
    sequence( :id ) { |n| 10000 + n  }
    sequence( :uri ) { |n| "/repositories/2/archival_objects/#{ 10000 + n }" }
    sequence(:position) { |n| n }
    # repository_id { 2 }
    repository
    api_response { test_response(:archival_object) }
  end

  factory :user do
  end

  factory :digital_object do
    sequence( :id ) { |n| 10000 + n  }
    # repository_id { 2 }
    repository
    sequence( :uri ) { |n| "/repositories/2/digital_objects/#{ 10000 + n }" }
  end

  factory :agent_association do
  end

  factory :subject_association do
  end

  factory :digital_object_association do
  end

  factory :aspace_import do
  end

end
