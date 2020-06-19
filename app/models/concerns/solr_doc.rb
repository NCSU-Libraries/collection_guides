require 'active_support/concern'

module SolrDoc
  extend ActiveSupport::Concern

  included do

    include ActionView::Helpers::SanitizeHelper

    begin
    include SolrDocCustom
    rescue
    end

    before_destroy :delete_from_index

    # Updates the record in the Solr index
    def update_index
      SearchIndex.update_record(self)
    end

    # Remove the record from the Solr index
    def delete_from_index
      SearchIndex.delete_record(self)
    end

    # Prepare Solr document hash for the record
    def solr_doc_data
      data = parse_unit_data
      doc = {}
      doc[:title] = title
      doc[:record_type] = self.class.to_s.underscore
      doc[:record_id] = self.id
      doc[:uri] = uri
      doc[:primary_agent] = data[:primary_agent]
      doc[:abstract] = strip_tags(data[:abstract])
      doc[:date_statement] = data[:date_statement]
      doc[:extent_statement] = data[:extent_statement]
      doc[:notes] = []
      doc[:inclusive_years] = data[:inclusive_years]
      doc[:id_0] = data[:id_0]

      if data[:notes]
        data[:notes].each do |k,v|
          v.each { |note| doc[:notes] << note[:content] }
        end
      end

      doc[:primary_agent] = data[:primary_agent]

      agents.each do |a|
        (doc[:agents] ||= []) << a.display_name
        (doc[:agents_uri] ||= []) << a.uri
        (doc[:agents_id] ||= []) << a.id
      end

      subjects.each do |s|
        (doc[:subjects] ||= []) << s.subject
        (doc[:subjects_uri] ||= []) << s.uri
        (doc[:subjects_id] ||= []) << s.id
      end

      case self
      when Resource
        add_resource_fields(doc, data)
      when ArchivalObject
        add_archival_object_fields(doc, data)
      end

      # ***
      # TO DO: Calcualted dates
      # ***

      add_local_fields(doc, data)

      doc.delete_if { |k,v| v.blank? }

      doc
    end


    def add_resource_fields(doc, data)
      doc[:identifier] = data[:identifiers]
      doc[:resource_uri] = uri
      doc[:resource_title] = title
      doc[:resource_id] = id
      doc[:repository_id] = repository_id
      doc[:resource_collection_id] = data[:collection_id]
      doc[:resource_abstract] = strip_tags(data[:abstract])
      doc[:resource_primary_agent] = data[:primary_agent]
      doc[:resource_date_statement] = data[:date_statement]
      doc[:resource_extent_statement] = data[:extent_statement]
      if has_digital_objects_with_files || has_descendant_digital_objects_with_files
        doc[:resource_digital_content] = true
      end
      doc[:resource_eadid] = eadid
      doc[:eadid] = eadid
      doc
    end


    def add_archival_object_fields(doc, data)
      doc[:identifier] = data[:component_id]
      if resource
        r_data = resource.parse_unit_data
        doc[:resource_uri] = resource.uri
        doc[:resource_title] = resource.title
        doc[:resource_id] = resource.id
        doc[:resource_collection_id] = r_data[:collection_id]
        doc[:resource_abstract] = strip_tags(r_data[:abstract])
        doc[:resource_primary_agent] = r_data[:primary_agent]
        doc[:resource_date_statement] = r_data[:date_statement]
        doc[:resource_extent_statement] = r_data[:extent_statement]
        doc[:component_ancestors_title] = ancestors.map { |x| x.title }
        doc[:component_ancestors_id] = ancestors.map { |x| x.id }

        if has_digital_objects
          doc[:digital_content] = true
        end

        if resource.has_digital_objects || resource.has_descendant_digital_objects
          doc[:resource_digital_content] = true
        end

        doc[:resource_eadid] = resource.eadid
        doc[:containers] = data[:containers]
      else

        puts "ERROR indexing ArchivalObject #{ id.to_s }"
        puts "No resource found"
        puts; puts self.inspect; puts
        puts "Continuing in 10 seconds..."
        puts
        sleep 10
      end
      doc
    end

  end

end
