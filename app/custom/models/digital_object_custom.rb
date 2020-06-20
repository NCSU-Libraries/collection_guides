require 'active_support/concern'

module DigitalObjectCustom
  extend ActiveSupport::Concern

  included do

    ### BEGIN - Custom methods

    def self.custom_test
      puts "This comes from DigitalObjectCustom"
    end

    ### END - Custom methods

  end

end
