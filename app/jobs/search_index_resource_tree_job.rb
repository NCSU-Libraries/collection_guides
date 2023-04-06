class SearchIndexResourceTreeJob < ApplicationJob
  queue_as :index

  def perform(resource_id)
    SearchIndexResourceTreeService.call(resource_id: resource_id.to_i)
  end

end
