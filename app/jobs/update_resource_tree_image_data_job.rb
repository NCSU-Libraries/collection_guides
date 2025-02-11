class UpdateResourceTreeImageDataJob < ApplicationJob
  queue_as :image_data

  def perform(resource)
    UpdateResourceTreeImageData.call(resource)
  end
end
