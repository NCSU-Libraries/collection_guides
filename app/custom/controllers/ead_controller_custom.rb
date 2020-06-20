require 'active_support/concern'

module EadControllerCustom
  extend ActiveSupport::Concern

  included do

    ### BEGIN - Custom methods/actions

    private

    def custom_test
      puts "Hello from EadControllerCustom"
    end

    ### END - Custom methods/actions

  end
end
