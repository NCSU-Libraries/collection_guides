class AddTermsToAgentAssociations < ActiveRecord::Migration[4.2]
  def change
    add_column :agent_associations, :terms, 'longtext'
  end
end
