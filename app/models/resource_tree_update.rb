class ResourceTreeUpdate < ApplicationRecord
  belongs_to :resource, optional: true

  before_create do
    if resource_uri && !resource_id
      resource_id = Pathname.new(resource_uri).basename.to_s.to_i
    end
  end


  def self.in_progress
    where('completed_at IS NULL')
  end


  def self.in_progress_for_resource?(resource_uri)
    update = self.where("completed_at IS NULL AND resource_uri='#{resource_uri}'").first
    update ? true : false
  end


  def self.completed_after_for_resource?(resource_uri, datetime)
    updates = self.where("resource_uri='#{resource_uri}' AND exit_status = 0").where("completed_at >= ?", datetime)
    (updates.length > 0) ? true : false
  end


  def self.completed_before_for_resource?(resource_uri, datetime)
    updates = self.where("resource_uri='#{resource_uri}' AND exit_status = 0").where("completed_at <= ?", datetime)
    (updates.length > 0) ? true : false
  end


  def complete
    update!(exit_status: 0, completed_at: DateTime.now)
  end


  def complete_with_error(error_msg)
    update!(exit_status: 1, completed_at: DateTime.now, error: error_msg)
  end

end
