class UpdateResourceTreeJob < ApplicationJob
  queue_as :update

  # def perform(resource_id, aspace_import_id=nil)
  #   r = Resource.find resource_id
  #   update_response = UpdateResourceTreeService.call(r.id)
  # end

  def perform(resource_uri)
    resource_id = Pathname.new(resource_uri).basename.to_s.to_i
    resource_tree_update = ResourceTreeUpdate.create!(resource_id: resource_id)
    begin
      service_response = UpdateResourceTreeService.call(resource_uri)
      if !service_response['error']
        resource_tree_update.complete
      else
        raise service_response[:error]
      end
    rescue Exception => e
      resource_tree_update.complete_with_error(e)
    end
  end

end
