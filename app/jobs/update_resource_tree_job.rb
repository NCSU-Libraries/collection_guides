class UpdateResourceTreeJob < ApplicationJob
  queue_as :update

  # def perform(resource_id, aspace_import_id=nil)
  #   r = Resource.find resource_id
  #   update_response = UpdateResourceTreeService.call(r.id)
  # end

  def perform(resource_uri, aspace_import_id=nil)
    update_response = UpdateResourceTreeService.call(resource_uri)
  end

end
