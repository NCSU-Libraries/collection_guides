class UpdateResourceTreeUnitDataJob < ApplicationJob
  queue_as :update

  def perform(resource_id = nil)
    if resource_id
      r = Resource.find resource_id
      r.update_tree_unit_data
    else
      Resource.find_each { |r| r.update_tree_unit_data }
    end
  end
end
