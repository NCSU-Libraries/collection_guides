require 'active_support/concern'

module ApiResponseData
  extend ActiveSupport::Concern

  include AspaceContentUtilities
  include ControlledVocabularyUtilities

  included do

    after_save :update_unit_data

    # Class method - calls update_unit_data() for all records of class
    def self.update_unit_data
      print "Updating #{self.to_s} unit data"
      find_each { |r| r.update_unit_data; print '.' }
      puts
    end

    # Convert a record's unit_data attribute (JSON string) to HashWithIndifferentAccess
    # (treats strings and symbols the same when used as keys)
    def parse_unit_data
      ActiveSupport::HashWithIndifferentAccess.new(JSON.parse(unit_data))
    end

    # Update a record's unit_data attribute based on currently stored
    # API response and existing associations
    def update_unit_data
      @data = {}
      response_data = JSON.parse(api_response)

      self.attributes.each do |k,v|
        if !['api_response','unit_data','structure'].include?(k)
          if v.kind_of? String
            value = escape_ampersands(v)
            @data[k.to_sym] = convert_ead_elements(value)
          else
            @data[k.to_sym] = v
          end
        end
      end

      @data[:notes] = parse_notes(response_data['notes'])

      add_language_and_script_to_notes

      if response_data['finding_aid_sponsor']
        @data[:notes] ||= {}
        @data[:notes][:sponsor] = [ { content: "<p>#{response_data['finding_aid_sponsor']}</p>" } ]
      end

      @data[:date_statement] = generate_date_statement(response_data['dates'])
      @data[:extent_statement] = generate_extent_statement(response_data['extents'])
      @data[:inclusive_years] = generate_inclusive_years(response_data['dates'])

      # move abstract out of notes
      @data[:abstract] = abstract_from_notes(@data[:notes])
      @data[:notes].delete(:abstract)

      @data[:identifiers] = [response_data['id_0'],response_data['id_1'],response_data['id_2'],response_data['id_3']]
      @data[:identifiers].delete_if { |x| x.nil? }

      if self.class == Resource
        @data[:id_0] = !@data[:identifiers].empty? ? @data[:identifiers].first : nil
        @data[:collection_id] = @data[:id_0]
      end

      @data[:primary_agent] = get_primary_agent_list

      add_subjects_to_unit_data()

      add_agents_to_unit_data()

      add_instances_to_unit_data(response_data)

      add_digital_objects_to_unit_data()

      update_unit_data_custom()

      @data.delete_if { |k,v| v.blank? }

      # update_column will skip callbacks
      update_column(:unit_data, JSON.generate(@data))
      touch
    end
  end


  def add_language_and_script_to_notes
    data = JSON.parse(api_response)
    if data['lang_materials'].is_a?(Array) && !data['lang_materials'].empty?
      langs =[]
      data['lang_materials'].each do |l|
        if l['language_and_script']
          lang_code = l['language_and_script']['language']
          script_code = l['language_and_script']['script']
          if lang_code != 'eng'
            language = language_string_to_code.key(lang_code)
            if language  
              if script_code != 'Latn'
                script = script_code_to_label[script_code]
                if script
                  language += " (#{script})"
                end
              end
              langs << language
            end
          end
        end
      end
      if !langs.empty?
        note = { content: langs.join('; '), position: 0, label: 'Language of materials' }
        @data[:notes][:langmaterial] = note
      end
    end
  end


  # Included to enable custom additions to update_unit_data()
  def update_unit_data_custom
  end

  private

  #
  def add_subjects_to_unit_data
    if has_subjects
      @data[:subjects] = []
      subjects.each do |s|
        @data[:subjects] << {
          id: s.id,
          uri: s.uri,
          subject: s.subject,
          subject_root: s.subject_root,
          subject_type: s.subject_type,
          subject_source_uri: s.subject_source_uri
        }
      end
    end
  end

  #
  def add_agents_to_unit_data
    if has_agents
      @data[:agents] = []

      # avoid duplicates by storing agent display names in array and checking against it before processing
      # using display names rather than ids because the same agent might appear with different subdivisions
      display_names = []

      agent_associations.each do |aa|
        a = aa.agent
        extension = ''

        if !aa.terms.blank?
          JSON.parse(aa.terms).each do |t|
            if !t['term'].blank?
              extension << " -- #{t['term']}"
            end
          end
        end

        display_name = a.display_name + extension

        if !display_names.include? display_name
          display_names << display_name
          agent_data = {
            id: a.id,
            uri: a.uri,
            # display_name: a.display_name,
            display_name: escape_ampersands(display_name),
            agent_type: a.agent_type,
            role: aa.role,
            relator: aa.relator
          }
          relator_data = marc_relators(aa.relator)
          agent_data[:relator_term] = relator_data[:label]
          agent_data[:relator_uri] = relator_data[:uri]
          @data[:agents] << agent_data
        end
      end
    end
  end

  #
  def add_instances_to_unit_data(response_data)
    container_string = lambda do |type,indicator|
      container = type ? (container_type_labels(type) || type) : ''
      container += indicator ? " #{indicator}" : ''
      return container
    end

    if response_data['instances']
      response_data['instances'].each do |i|
        containers = []
        sub_c = i['sub_container']
        if sub_c
          if sub_c['top_container'] && sub_c['top_container']['_resolved']
            type = sub_c['top_container']['_resolved']['type']
            indicator = sub_c['top_container']['_resolved']['indicator']
            containers << container_string.(type,indicator)
          end

          [2,3].each do |x|
            type = sub_c["type_#{x.to_s}"]
            indicator = sub_c["indicator_#{x.to_s}"]
            if type
              containers << container_string.(type,indicator)
            end
          end

          (@data[:containers] ||= []) << containers.join(', ')
        end
      end
    end
  end

  #
  def add_digital_objects_to_unit_data
    if has_digital_objects
      @data[:digital_objects] = []
      digital_objects.each do |d|
        if d.publish
          do_data = d.presenter_data
          @data[:digital_objects] << do_data
        end
      end
    end
  end
end
