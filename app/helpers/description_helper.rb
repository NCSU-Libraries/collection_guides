module DescriptionHelper
  include AspaceContentUtilities
  include ActionView::Helpers::TagHelper


  # Defines order of fields in summary display
  def note_elements
    [
      # Description of materials, context
      'abstract', 'langmaterial', 'bioghist', 'scopecontent', 'custodhist', 'odd', 'bibliography',
      # Information regarding access to materials
      'physdesc', 'physloc', 'arrangement', 'accessrestrict', 'userestrict', 'legalstatus', 'prefercite',
      'phystech', 'altformavail', 'originalsloc', 'otherfindaid', 'materialspec', 'relatedmaterial',
      # Information regarding acquitition and processing
      'acqinfo', 'appraisal', 'separatedmaterial', 'accruals', 'processinfo',
      # and sponsor, which actually comes from eadheader
      'sponsor'
    ]
  end


  def element_label(element)
    config = element_config(element)
    config[:label]
  end


  def element_property(element)
    config = element_config(element)
    config[:property]
  end


  def element_config(element)
    config = ActiveSupport::HashWithIndifferentAccess.new
    elements = [:abstract, :accessrestrict, :accruals, :acqinfo, :altformavail, :appraisal,
      :arrangement, :bibliography, :bioghist, :container, :custodhist, :extent, :langmaterial,
      :language, :legalstatus, :materialspec, :odd, :originalsloc, :origination, :otherfindaid,
      :physdesc, :physical_location, :physloc, :phystech, :prefercite, :processinfo, :relatedmaterial,
      :scopecontent, :separatedmaterial, :userestrict, :sponsor
    ]

    elements.each do |e|
      config[e] = {}
      config[e][:label] = I18n.t "#{e.to_s}_label"
    end

    config[:abstract][:property] = ['schema:description', 'dcterms:abstract']
    config[:accessrestrict][:property] = ['dcterms:accessRights']
    config[:accruals][:property] = ['dcterms:accrualMethod']
    config[:acqinfo][:property] = ['dcterms:provenance']
    config[:custodhist][:property] = ['dcterms:provenance']
    config[:extent][:property] = ['dcterms:extent']
    config[:langmaterial][:property] = ['schema:inLanguage']
    config[:language ][:property] = ['schema:inLanguage']
    config[:origination][:property] = ['schema:creator', 'dcterms:creator']
    config[:physdesc][:property] = ['dcterms:extent']
    config[:physical_location][:property] = ['schema:contentLocation']
    config[:prefercite][:property] = ['schema:citation', 'dcterms:bibliographicCitation']
    config[:relatedmaterial][:property] = ['dcterms:relation']
    config[:scopecontent][:property] = ['dcterms:description']
    config[:separatedmaterial][:property] = ['dcterms:relation']

    config[element]
  end


  def bioghist_label(creators=nil)
    creator_types = []
    if creators
      creators.each do |c|
        if c['_resolved']
          creator_types << c['_resolved']['jsonmodel_type']
        end
      end
    end
    creator_types.uniq!
    if creator_types.length == 1
      creator_types.first == 'agent_person' ? 'Biographical note' : 'Historical note'
    elsif creator_types.include?('agent_person')
      'Biographical/historical note'
    else
      'Historical note'
    end
  end


  def note_label(element, note={})
    if element == 'bioghist' && defined? @creator_agents
      bioghist_label(@creator_agents)
    elsif element_label(element)
      element_label(element)
    elsif note['label']
      note['label']
    else
      'Note'
    end
  end


  def rdfa_property_attribute(element)
    output = ''
    properties = element_property(element)
    if !properties.blank?
      output = " property=\"#{properties.join(' ')}\""
    end
    output
  end


  def inline_description_element(element,value,label=nil)
    output = "<div class=\"description-element #{element.to_s}\"#{rdfa_property_attribute(element.to_sym)}>"

    if label
      output += "<span class=\"element-label\">#{label}</span>: "
    end
    output += "<span class=\"element-value\">#{value}</span>"
    output += '</div>'
    output.html_safe
  end



  # Note: For helpers that take data as an argument, data = ASpace API response converted to a Hash

  # Temporary - needs work
  # def extent_statement(data)
  #   extents = []
  #   if data['extents']
  #     data['extents'].each do |e|
  #       extents << "#{e['number']} #{e['extent_type']}"
  #     end
  #   end
  #   extents.join(', ')
  # end


  # Temporary - needs work
  # def date_statement(data)
  #   dates = []
  #   dates_bulk = []

  #   if data['dates']
  #     data['dates'].each do |d|
  #       date = ''

  #       if d['expression']
  #         date = d['expression']
  #       elsif d['begin'] || d['end']
  #         date = "#{d['begin'] || ''} - #{d['end'] || ''}"
  #       end

  #       if !date.empty?
  #         case d['date_type']
  #         when 'bulk'
  #           dates_bulk << date
  #         else
  #           dates << date
  #         end
  #       end
  #     end
  #   end

  #   output = ''

  #   if !(dates.empty? && dates_bulk.empty?)
  #     if !dates.empty?
  #       output += dates.join(', ')
  #       if !dates_bulk.empty?
  #         output += ' (bulk '
  #       end
  #     end

  #     if !dates_bulk.empty?
  #       output += dates_bulk.join(', ')
  #       if !dates.empty?
  #         output += ')'
  #       end
  #     end
  #   end

  #   output
  # end







  # Load custom methods if they exist
  begin
    include DescriptionHelperCustom
  rescue
  end


end
