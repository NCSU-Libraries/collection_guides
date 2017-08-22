class AgentAssociation < ActiveRecord::Base

  include ControlledVocabularyUtilities

  belongs_to :record, polymorphic: true
  belongs_to :agent

  def relator_term
    if relator && marc_relators(relator)
      marc_relators(relator)[:label]
    end
  end


  # Load custom methods if they exist
  begin
    include AgentAssociationCustom
  rescue
  end

end
