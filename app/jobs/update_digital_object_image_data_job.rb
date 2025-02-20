class UpdateDigitalObjectImageDataJob < ApplicationJob
  queue_as :image_data

  def perform(digital_object, options = {})
    AddOrUpdateDigitalObjectImageData.call(digital_object, options)
  end
end
