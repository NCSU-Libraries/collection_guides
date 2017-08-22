class SubjectAssociation < ActiveRecord::Base

  belongs_to :record, polymorphic: true
  belongs_to :subject


  # Load custom methods if they exist
  begin
    include SubjectAssociationCustom
  rescue
  end

end
