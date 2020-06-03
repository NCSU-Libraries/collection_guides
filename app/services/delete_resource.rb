class DeleteResource

  include GeneralUtilities


  def self.call(resource_id)
    object = new(resource_id)
    object.call
  end


  def initialize(resource_id)
    @resource_id = resource_id
    @resource = Resource.find_by(id: resource_id)
  end


  def call
    log_info "DeleteResource called for resource id #{ @resource_id }"

    if !@resource
      log_info "Resource does not exist with id #{ @resource_id } ... abortin!"
    else
      execute_delete
    end
  end


  private


  def execute_delete
    delete_resource_associations
    delete_archival_object_associations
    delete_archival_objects
    @resource.destroy!
  end


  def delete_resource_associations
    ['agent_associations','subject_associations','digital_object_associations'].each do |a|
      sql = "DELETE FROM #{ a } WHERE record_type='Resource' AND record_id=#{ @resource_id }"
      puts sql
      ActiveRecord::Base.connection.exec_query(sql)
    end
  end


  def delete_archival_object_associations
    ['agent_associations','subject_associations','digital_object_associations'].each do |a|
      sql = "DELETE #{ a } FROM #{ a }
        JOIN archival_objects ao on ao.id = #{ a }.record_id
        WHERE #{ a }.record_type='ArchivalObject'
        AND ao.resource_id=#{ @resource_id }"
      puts sql
      ActiveRecord::Base.connection.exec_query(sql)
    end
  end


  def delete_archival_objects
    sql = "DELETE FROM archival_objects WHERE resource_id=#{ @resource_id }"
    puts sql
    ActiveRecord::Base.connection.exec_query(sql)
    solr_q = "record_type:archival_object AND resource_id:#{ @resource_id }"
    SearchIndex.delete_by_query(solr_q)
  end

end
