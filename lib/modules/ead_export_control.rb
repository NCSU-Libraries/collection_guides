module EadExportControl

  def control_add_recordid
    @control << create_element('recordid', @control_config[:recordid])
  end


  def control_add_otherrecordid
    @control << create_element('otherrecordid', @control_config[:ead_url], localtype: 'url')
  end


  def control_add_representation
    @control << create_element('representation', 'Collection guide', href: @control_config[:finding_aid_url], localtype: 'html')
  end


  def control_add_filedesc
    @filedesc = create_element('filedesc')

    # <titlestmt> *required
    @titlestmt = create_element('titlestmt')
    @titlestmt << create_element('titleproper', @control_config[:ead_title])
    @filedesc << @titlestmt

    # <editionstmt>
    if @resource_data['finding_aid_revision_date'] || @resource_data['finding_aid_revision_description']
      @editionstmt = create_element('editionstmt')
      if @resource_data['finding_aid_revision_date']
        @editionstmt << create_element('edition', "Revised: #{@resource_data['finding_aid_revision_date']}")
      end
      if @resource_data['finding_aid_revision_description']
        @editionstmt << create_element('p', remove_xml(@resource_data['finding_aid_revision_description']))
      end
      @filedesc << @editionstmt
    end

    # <publicationstmt>
    # NOT USED BY NCSU

    # <seriesstmt>
    # NOT USED BY NCSU

    # <notestmt>
    if @control_config[:filedesc_notes]
      @controlnote = create_element('controlnote')
      @control_config[:filedesc_notes].each do |n|
        @controlnote << create_element('p', n)
      end
      @notestmt = create_element('notestmt', @controlnote)
      @filedesc << @notestmt
    end
    @control << @filedesc
  end


  def control_add_maintenance_status
    status = @resource_data['finding_aid_revision_date'] ? 'revised' : 'new'
    @control << create_element('maintenancestatus', status, value: status)
  end


  def control_add_maintenanceagency
    @maintenanceagency = create_element('maintenanceagency')
    @maintenanceagency << create_element('agencycode', @control_config[:maintenanceagency_code])
    @maintenanceagency << create_element('agencyname', @control_config[:maintenanceagency_name])
    @control << @maintenanceagency
  end


  def control_add_languagedeclaration
    @languagedeclaration = create_element('languagedeclaration')
    @languagedeclaration << create_element('language', @control_config[:language], langcode: @control_config[:langcode])
    @languagedeclaration << create_element('script', @control_config[:script], scriptcode: @control_config[:scriptcode])
    @control << @languagedeclaration
  end


  def control_add_maintenancehistory
    @maintenanceevent = create_element('maintenanceevent')
    @maintenanceevent << create_element('eventtype', nil, value: 'created')
    @maintenanceevent << create_element('eventdatetime', nil, standarddatetime: DateTime.now.iso8601(0))
    @maintenanceevent << create_element('agenttype', nil, value: 'machine')
    @maintenanceevent << create_element('agent', 'NCSU Collection Guides Application')
    @maintenancehistory = create_element('maintenancehistory', @maintenanceevent)
    @control << @maintenancehistory
  end

end
