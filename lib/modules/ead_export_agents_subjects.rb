module EadExportAgentsSubjects

  def agent_type_element_name(agent_type)
    element_names = {
      'person' => 'persname',
      'corporate_entity' => 'corpname',
      'family' => 'famname'
    }
    element_names[agent_type]
  end


  def generate_name_element(agent_association)
    agent = agent_association.agent
    name_element = create_element(agent_type_element_name(agent.agent_type))
    agent_data = JSON.parse(agent.api_response)
    add_name_parts(agent_data, name_element)
    name_element
  end


  def generate_subject_element(subject_data)
    subject = create_element('subject')
    if subject_data['terms']
      subject_data['terms'].each do |t|
        subject << create_element('part', t['term'], localtype: t['term_type'])
      end
    else
      subject << create_element('part', t['title'])
    end
    subject
  end


  def add_name_parts(agent_data, name_element)

    agent_type = agent_data['jsonmodel_type'].gsub(/agent_/,'')

    name_data = agent_data['names'].first
    agent_data['names'].each do |n|
      if n['authorized'] || n['is_display_name']
        name_data = n
        break
      end
    end

    part_types = {
      'primary_name' => (agent_type == 'person') ? 'surname' : 'primaryPart',
      'family_name' => 'familyName',
      'rest_of_name' => 'forename',
      'subordinate_name_1' => 'secondaryPart',
      'subordinate_name_2' => 'tertiaryPart',
      'prefix' => 'prefix',
      'suffix' => 'suffix',
      'title' => 'title',
      'number' => 'number',
      'fuller_form' => 'fullerForm',
      'qualifier' => 'qualifier'
    }

    single_part = (part_types.keys & name_data.keys) == ['primary_name'] ? true : false

    name_data.each do |k,v|
      if part_types[k]
        attributes = single_part ? {} : {localtype: part_types[k]}
        name_element << create_element('part', v, attributes)
      end
    end

    if !agent_data['dates_of_existence'].blank? && agent_type == 'person'
      date_data = agent_data['dates_of_existence'].first
      if date_data['expression']
        dates = date_data['expression']
      else
        dates = "#{date_data['begin'] || ''}-#{date_data['end'] || ''}"
      end
      name_element << create_element('part', dates, localtype: 'existDates')
    end

    name_source_rules(name_data).each { |k,v| name_element[k] = v }
  end


  def name_source_rules(name_data)
    source_rules = {}
    ['source','rules'].each do |k|
      if name_data[k]
        source_rules[k] = name_data[k]
      end
    end
    source_rules
  end

end
