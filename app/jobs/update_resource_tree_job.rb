class UpdateResourceTreeJob < ApplicationJob
  queue_as :update

  def perform(resource_id, aspace_import_id=nil)
    r = Resource.find resource_id
    update_response = UpdateResourceTree.call(r.id)
    
  end

end
