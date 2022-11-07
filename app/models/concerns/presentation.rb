module Presentation

  # The Presenter class packages all displayable attributes for a given record into a single object
  class Presenter

    attr_accessor :data, :record, :title, :uri, :level, :position, :resource_id, :component_id,
      :resource_title, :resource_uri, :notes, :abstract, :date_statement, :extent_statement,
      :collection_id, :primary_agent, :containers, :response_data, :has_children, :tree_size,
      :total_components, :subjects, :agents, :digital_objects, :alt_digital_object_url, :has_descendant_digital_objects,
      :has_digital_objects_with_files, :has_descendant_digital_objects_with_files

    def initialize(record)
      @record = record
      @data = @record.parse_unit_data
      @title = @data[:title]
      @uri = @record.uri
      @record_id = @record.id

      case @record

      when Resource
        @resource_id = @record.id
        @resource_title = @data[:title]
        @resource_uri = @record.uri
        @tree_size = @record.total_components
        @total_components = @record.total_components
        @alt_digital_object_url = @data[:alt_digital_object_url]
      when ArchivalObject
        @level = @record.level
        @position = @record.position
        # if @record.resource
        #   @resource_id = @record.resource.id
        #   @resource_title = @record.resource.title
        #   @resource_uri = @record.resource.uri
        # end
        @component_id = @record.component_id
      end
      @notes = @data[:notes] || {}
      @abstract = @data[:abstract]
      @date_statement = @data[:date_statement]
      @extent_statement = @data[:extent_statement]
      @collection_id = @data[:collection_id]
      @subjects = @data[:subjects]
      @agents = @data[:agents]
      @containers = @data[:containers]
      @primary_agent = @data[:primary_agent]
      @digital_objects = @data[:digital_objects]
      @has_children = @record.has_children
    end


    # Convenience method that allows has_digital_object to be called on the record via the Presenter
    def has_digital_objects
      @record.has_digital_objects
    end


    # Convenience method that allows has_digital_object to be called on the record via the Presenter
    def has_digital_objects_with_files
      @record.has_digital_objects_with_files
    end


    # Convenience method that allows has_descendant_digital_objects to be called on a Resource via the Presenter
    def has_descendant_digital_objects
      if @record.class == Resource
        @record.has_descendant_digital_objects
      end
    end


    # Convenience method that allows has_descendant_digital_objects_with_files to be called on a Resource via the Presenter
    def has_descendant_digital_objects_with_files
      if @record.class == Resource
        @record.has_descendant_digital_objects_with_files
      end
    end


    # has_descendant_digital_objects_with_files

    # Convenience method that allows id_tree to be called on a Resource via the Presenter
    # IS THIS BEING USED?
    def id_tree
      if @record.class == Resource
        deeper_symbolize_keys(JSON.parse(@record.structure))
      end
    end

  end


end
