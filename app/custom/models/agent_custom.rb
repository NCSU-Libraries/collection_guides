require 'active_support/concern'

module AgentCustom
  extend ActiveSupport::Concern

  included do

    ### BEGIN - Custom methods

    def self.custom_test
      puts "Hello from AgentCustom"
    end

    ### END - Custom methods

  end

end
