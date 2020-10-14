class UpdateResourceTreeJob < ApplicationJob
  queue_as :update

  def perform(resource_id)
    r = Resource.find resource_id
    UpdateResourceTree.call(r.id)
  end

end
