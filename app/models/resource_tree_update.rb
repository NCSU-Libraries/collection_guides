class ResourceTreeUpdate < ApplicationRecord
  belongs_to :resource, optional: true

  def self.in_progress
    where('completed_at IS NULL')
  end


  def self.in_progress_for_resource(resource_id)
    self.where("completed_at IS NULL AND resource_id=#{resource_id}").first
  end


  def complete
    update_attributes(exit_status: 0, completed_at: DateTime.now)
  end


  def complete_with_error(error_msg)
    update_attributes(exit_status: 1, completed_at: DateTime.now, error: error_msg)
  end

end
