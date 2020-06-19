require 'active_support/concern'

module SearchCustom
  extend ActiveSupport::Concern

  included do

    ### BEGIN - Custom methods

    def self.custom_test
      puts "This comes from SearchCustom"
    end

    ### END - Custom methods

  end
end
