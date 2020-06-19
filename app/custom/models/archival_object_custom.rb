require 'active_support/concern'

module ArchivalObjectCustom
  extend ActiveSupport::Concern

  included do

    ### BEGIN - Custom methods

    def self.custom_test
      puts "This comes from ArchivalObjectCustom"
    end

    ### END - Custom methods

  end
end
