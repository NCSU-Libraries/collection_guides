require 'active_support/concern'

module ResourcesControllerCustom
  extend ActiveSupport::Concern

  included do

    ### BEGIN - Custom methods/actions

    private

    def custom_test
      puts "Hello from ResourcesControllerCustom"
    end

    ### END - Custom methods/actions

  end
end
