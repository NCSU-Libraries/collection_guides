class AspaceImport < ApplicationRecord

  # require 'general_utilities'
  include GeneralUtilities

  serialize :resource_list
  

  def self.last_import_date
    last = self.order('created_at DESC').limit(1).first
    last ? last.created_at : nil
  end


  # Load custom methods if they exist
  begin
    include AspaceImportCustom
  rescue
  end


end
