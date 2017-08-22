class DigitalObjectAssociation < ActiveRecord::Base

  belongs_to :record, polymorphic: true
  belongs_to :digital_object

  # Load custom methods if they exist
  begin
    include DigitalObjectAssociationCustom
  rescue
  end

end
