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
        # collection_id is NCSU-specific - consider moving
        @data[:collection_id] = @data[:id_0]
      end

      @data[:primary_agent] = get_primary_agent_list

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

      if response_data['instances']
        response_data['instances'].each do |i|
          containers = []
          if i['container']
            (1..3).each do |x|
              type = i['container']["type_#{x.to_s}"]
              indicator = i['container']["indicator_#{x.to_s}"]
              if type
                container = container_type_labels(type);
                container += indicator ? " #{indicator}" : ''
                containers << container
              end
            end
            (@data[:containers] ||= []) << containers.join(', ')
          end
        end
      end

      if has_digital_objects
        @data[:digital_objects] = []
        digital_objects.each do |d|
          if d.publish
            do_data = d.presenter_data
            @data[:digital_objects] << do_data
          end
        end
      end

      update_unit_data_custom

      @data.delete_if { |k,v| v.blank? }

      # update_column will skip callbacks
      update_column(:unit_data, JSON.generate(@data))
      touch
    end

  end


  # Included to enable custom additions to update_unit_data()
  def update_unit_data_custom
  end



end
