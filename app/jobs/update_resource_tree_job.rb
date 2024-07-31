class UpdateResourceTreeJob < ApplicationJob
  queue_as :update

  # def perform(resource_id, aspace_import_id=nil)
  #   r = Resource.find resource_id
  #   update_response = UpdateResourceTreeService.call(r.id)
  # end

  def perform(resource_tree_update, options={})
    begin

      puts "UpdateResourceTreeJob"
      puts resource_tree_update.inspect
      puts "calling UpdateResourceTreeService"

      service_response = UpdateResourceTreeService.call(resource_tree_update.resource_uri)
      
      if !service_response[:error]
        resource_tree_update.complete
      else
        msg = "UpdateResourceTreeJob: error received from UpdateResourceTreeService: #{service_response[:error]}"
        raise msg
      end
    rescue Exception => e
      resource_tree_update.complete_with_error(e)
      raise e
    end
  end

end
