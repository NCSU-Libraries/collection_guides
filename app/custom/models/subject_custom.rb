require 'active_support/concern'

module SubjectCustom
  extend ActiveSupport::Concern

  included do

    ### BEGIN - Custom methods

    def self.custom_test
      puts "This comes from SubjectCustom"
    end

    ### END - Custom methods

  end

end
