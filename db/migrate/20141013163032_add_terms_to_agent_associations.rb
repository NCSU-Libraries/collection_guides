class AddTermsToAgentAssociations < ActiveRecord::Migration
  def change
    add_column :agent_associations, :terms, 'longtext'
  end
end
