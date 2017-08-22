module EadExportArchdesc

  include EadExportDates
  include EadExportAgentsSubjects
  include EadExportNotes


  def add_did(parent_element, record)
    did = create_element('did')
    data = JSON.parse(record.api_response)
    notes = parse_notes(data['notes'])

    # origination
    did_add_origination(did, record)

    # unittitle
    did_add_unittitle(did, record)

    # unitdate
    # unitdatestructured
    did_add_dates(did, data)

    # unitid
    did_add_unitid(did, data)

    # abstract
    add_note('abstract', did, notes)

    # container
    did_add_container(did, data)

    # dao
    did_add_dao(did, record)

    # didnote
    add_note('didnote', did, notes)

    # head

    # langmaterial
    did_add_langmaterial(did, notes)

    # materialspec
    add_note('materialspec', did, notes)

    # parallelphysdescset
    # physdesc
    # physdescstructured
    did_add_physdesc(did, data)

    # physloc
    add_note('physloc', did, notes)

    # repository
    did_add_repository(did, record)

    parent_element << did
  end


  def add_non_did_notes(parent_element, record)
    data = JSON.parse(record.api_response)
    notes = parse_notes(data['notes'])
    non_did_note_elements = [
      'accessrestrict', 'accruals', 'acqinfo', 'altformavail', 'appraisal',
      'arrangement', 'bibliography', 'bioghist', 'fileplan', 'index',
      'legalstatus', 'odd', 'originalsloc', 'otherfindaid', 'phystech',
      'prefercite', 'processinfo', 'relatedmaterial', 'relations', 'scopecontent',
      'separatedmaterial', 'userestrict'
    ]
    non_did_note_elements.each do |e|
      add_note(e, parent_element, notes)
    end
  end



  def add_controlaccess(parent_element, record)
    if (record.agent_associations.length + record.subject_associations.length) > 0
      controlaccess = create_element('controlaccess')
      record.agent_associations.each do |aa|
        controlaccess << generate_name_element(aa)
      end
      record.subject_associations.each do |sa|
        subject_data = JSON.parse(sa.subject.api_response)
        controlaccess << generate_subject_element(subject_data)
      end

      parent_element << controlaccess
    end
  end



  def archdesc_add_dsc
    @dsc = create_element('dsc')

    add_children = Proc.new do |parent_record, parent_element|
      parent_id = parent_record ? parent_record.id : nil
      children = @resource.archival_objects.where(parent_id: parent_id).order('position ASC')
      children.each do |c_record|
        c = create_element('c')
        add_did(c, c_record)
        add_non_did_notes(c, c_record)
        add_controlaccess(c, c_record)
        parent_element << c
        add_children.call(c_record, c)
      end
    end

    add_children.call(nil, @dsc)

    @archdesc << @dsc
  end


  def did_add_origination(did, record)
    agent_associations = record.agent_associations.where(role: 'creator').order('position ASC')
    if !agent_associations.empty?
      agent_associations.each do |aa|
        name_element = generate_name_element(aa)
        did << create_element('origination', name_element)
      end
    end
  end


  def did_add_unittitle(did, record)
    if !record.title.blank?
      did << create_element('unittitle', remove_xml(record.title))
    end
  end


  def did_add_unitid(did, data)
    if data['id_0']
      did << create_element('unitid', data['id_0'])
    end
  end


  def did_add_container(did, data)
    if data['instances']
      data['instances'].each do |i|
        if i['container']
          (1..3).each do |x|
            type = i['container']["type_#{x.to_s}"]
            indicator = i['container']["indicator_#{x.to_s}"]
            if type
              did << create_element('container', indicator, localtype: type)
            end
          end
        end
      end
    end
  end


  def did_add_repository(did, record)
    repo = record.repository
    add_repo = false
    if record.class == Resource
      add_repo = true
    elsif record.class == ArchivalObject
      if record.repository_id && (record.repository_id != record.resource.repository_id)
        add_repo = true
      end
    end

    if repo && add_repo
      repository = create_element('repository')
      repo_data = JSON.parse(repo.api_response)
      if repo_data['name']
        corpname = create_element('corpname')
        corpname << create_element('part', repo_data['name'])
        repository << corpname
        did << repository
      end
    end

  end


  def did_add_physdesc(did, data)
    if !data['extents'].blank?
      physdesc_elements = []
      physdescstructured_elements = []
      data['extents'].each do |e|
        if e['number'] && e['extent_type']
          ps = create_element('physdescstructured')

          # physdescstructuredtype
          ps_type = 'spaceoccupied'
          if !e['extent_type'].match(/lin(ear)?[_\s]f[eo]{2}?t\.?/i) && !e['extent_type'].match(/cu(bic)?[_\s]f[eo]{2}?t\.?/i)
            ps_type = 'carrier'
          end
          ps['physdescstructuredtype'] = ps_type

          # coverage
          ps['coverage'] = e['portion']

          if e['number']
            ps << create_element('quantity', e['number'])
          end
          if e['extent_type']
            ps << create_element('unittype', e['extent_type'].gsub(/_/,' '))
          end
          physdescstructured_elements << ps
        end
        if e['container_summary']
          physdesc_elements << create_element('physdesc', e['container_summary'])
        end
      end
      if physdescstructured_elements.length == 1
        physdescstructured_elements.each { |p| did << p }
      elsif physdescstructured_elements.length > 1
        parallelphysdescset = create_element('parallelphysdescset')
        physdescstructured_elements.each { |p| parallelphysdescset << p }
        did << parallelphysdescset
      end
      physdesc_elements.each { |p| did << p }
    end
  end


  def did_add_dao(did, record)

    if record.digital_object_associations.length > 0
      record.digital_object_associations.each do |da|
        d = da.digital_object
        if d.publish
          do_data = JSON.parse(d.api_response)
          if do_data['file_versions']
            do_data['file_versions'].each do |f|
              if f['file_uri']
                dao = create_element('dao', nil, href: f['file_uri'], daotype: 'unknown')
                did << dao
              end
            end
          end
        end
      end
    end

  end


  def did_add_langmaterial(did, notes_data)
    if notes_data[:langmaterial]
      notes_data[:langmaterial].each do |note|
        langmaterial = create_element('langmaterial')
        langmaterial << create_element('language', note[:content])
        did << langmaterial
      end
    end
  end

end
