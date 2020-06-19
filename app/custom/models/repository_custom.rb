require 'active_support/concern'

module RepositoryCustom
  extend ActiveSupport::Concern

  included do

    ### BEGIN - Custom methods

    def self.custom_test
      puts "This comes from RepositoryCustom"
    end

    ### END - Custom methods

  end
end
