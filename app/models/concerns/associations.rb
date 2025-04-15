require 'active_support/concern'

module Associations
  extend ActiveSupport::Concern

  included do

    # Replacement for standard has_many_through association for agents
    def agents
      all_agents = []
      agent_associations.each do |aa|
        all_agents << aa.agent
      end
      all_agents.uniq
    end


    # Returns all agents with role 'creator' associated with the reocord
    def creators
      list = []
      agent_associations.each do |aa|
        if aa.role == 'creator'
          list << aa.agent
        end
      end
      list
    end


    # Returns associated agents in a hash organized by role
    def get_agents_by_role
      agents_by_role = {}
      agent_associations.each do |aa|
        (agents_by_role[aa.role] ||= []) << aa.agent
      end
      agents_by_role
    end


    # Returns display names for associated creators in an array
    def get_primary_agent_list
      primary_agent_list = []
      agents_by_role = get_agents_by_role
      if agents_by_role['creator']
        agents_by_role['creator'].each { |a| primary_agent_list << a.display_name}
      end

      primary_agent_list.empty? ? nil : primary_agent_list
    end


    # Update hash_children attribute (for applicable classes)
    def update_has_children
      if respond_to?(:has_children)
        update_column(:has_children, (children.count > 0) ? true : false)
      end
    end


    # Returns true if the record has associated subjects
    def has_subjects
      (subjects.length > 0) ? true : false
    end


    # Returns true if record has associated agents
    def has_agents
      (agents.length > 0) ? true : false
    end


    # Returns true if record has associated digital objects
    def has_digital_objects
      if self.class != DigitalObject
        (digital_objects.length > 0) ? true : false
      else
        nil
      end
    end


    # Returns true if record has associated digital objects with files
    def has_digital_objects_with_files
      if self.class != DigitalObject
        dos = digital_objects.where(has_files: true)
        (dos.length > 0) ? true : false
      else
        false
      end
    end


    # Updates (or creates) agents associated with a record
    # Params:
    # +linked_agents+:: Array of resolved agent records (as Ruby hashes) included in an API response
    # +options+:: Options passed from another method to be passed downstream
    def update_associated_agents_from_data(linked_agents, options={})
      associations = agent_associations.clone

      old_associations = associations.to_a

      linked_agents.each_index do |i|
        a = linked_agents[i]
        if a['_resolved']
          agent = Agent.create_or_update_from_data(a["_resolved"], options)
        else
          raise "Association cannot be built without resolved agent. This is a problem with the API request."
        end

        match_attributes = { agent_id: agent.id, role: a['role'] }
        association_attributes = match_attributes.merge( { position: i, relator: a['relator']} )

        if !a['terms'].blank?
          association_attributes[:terms] = JSON.generate(a['terms'])
        end

        existing_association = associations.where(match_attributes).first

        if existing_association
          old_associations.delete(existing_association)
          existing_association.update!(association_attributes)
        else
          new_association = agent_associations.build(association_attributes)
          new_association.save
        end

      end
      # delete old associations
      old_associations.each { |o| o.destroy }
      self
    end


    # Updates (or creates) subjects associated with a record
    # Params:
    # +linked_subjects+:: Array of resolved subject records (as Ruby hashes) included in an API response
    # +options+:: Options passed from another method to be passed downstream
    def update_associated_subjects_from_data(linked_subjects, options={})
      associations = subject_associations.clone
      old_associations = associations.to_a

      linked_subjects.each_index do |i|
        s = linked_subjects[i]
        if s['_resolved']
          subject = Subject.create_or_update_from_data(s["_resolved"],options)
        else
          raise "Association cannot be built without resolved subject. This is a problem with the API request."
        end

        match_attributes = { subject_id: subject.id }
        association_attributes = match_attributes.merge( { position: i } )
        existing_association = associations.where(match_attributes).first

        if existing_association
          old_associations.delete(existing_association)
          existing_association.update!(association_attributes)
        else
          new_association = subject_associations.build(association_attributes)
          new_association.save
        end

      end
      # delete old associations
      old_associations.each { |o| o.destroy }
      self
    end


    # Updates (or creates) digital objects associated with a record
    # Params:
    # +instances+:: An array of instances associated with the record (as Ruby hash), each representing either a container or a digital_object
    # +options+:: Options passed from another method to be passed downstream
    def update_associated_digital_objects_from_data(instances, options={})
      associations = digital_object_associations.clone
      old_associations = associations.to_a
      p = 0

      instances.each do |i|
        if i['instance_type'] == 'digital_object'

          if i['digital_object'] && i['digital_object']['ref']
            api_data = DigitalObject.get_data_from_api(i['digital_object']['ref'],options)


            digital_object = DigitalObject.create_or_update_from_data(api_data, options)
            match_attributes = { digital_object_id: digital_object.id }
            association_attributes = match_attributes.merge( { position: p } )
            existing_association = associations.where(match_attributes).first

            if existing_association
              old_associations.delete(existing_association)
              existing_association.update!(association_attributes)
            else
              new_association = digital_object_associations.build(association_attributes)
              new_association.save
            end

            p += 1


            # OLD PROCEDURE _ MARKED FOR DELETION
            # # Currently we're only importing digital objects with links (file_versions >> file_uri)
            # # This keeps out digital objects created for born digital materials (for which there is currently no linkable access version)
            # if has_file_uri.call(api_data)
            #   # digital_object = DigitalObject.create_or_update_from_api(i['digital_object']['ref'],options)
            #   digital_object = DigitalObject.create_or_update_from_data(api_data, options)
            #   match_attributes = { digital_object_id: digital_object.id }
            #   association_attributes = match_attributes.merge( { position: p } )
            #   existing_association = associations.where(match_attributes).first

            #   if existing_association
            #     old_associations.delete(existing_association)
            #     existing_association.update!(association_attributes)
            #   else
            #     new_association = digital_object_associations.build(association_attributes)
            #     new_association.save
            #   end

            #   p += 1
            # end
            # END OLD PROCEDURE _ MARKED FOR DELETION


          else
            raise "Association cannot be built without digital_object ref. This is a problem with the API request."
          end

        end
      end

      # delete old associations
      old_associations.each { |o| o.destroy }
      self
    end

  end


end
