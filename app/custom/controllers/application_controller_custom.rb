require 'active_support/concern'

module ApplicationControllerCustom
  extend ActiveSupport::Concern

  included do

    ### BEGIN - Custom methods/actions

    private

    def custom_test
      puts "Hello from ApplicationControllerCustom"
    end

    ### END - Custom methods/actions

  end
end
