require 'active_support/concern'

module SearchControllerCustom
  extend ActiveSupport::Concern

  included do

    ### BEGIN - Custom methods/actions

    private

      def custom_test
        puts "Hello from SearchControllerCustom"
      end

    ### END - Custom methods/actions

  end
end
