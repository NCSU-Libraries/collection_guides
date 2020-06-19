require 'active_support/concern'

module UserCustom
  extend ActiveSupport::Concern

  included do

    ### BEGIN - Custom methods

    def self.custom_test
      puts "This comes from UserCustom"
    end

    ### END - Custom methods

  end
end
