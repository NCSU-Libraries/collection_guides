require 'active_support/concern'

module ResourcesControllerCustom
  extend ActiveSupport::Concern

  included do

    ### Custom methods/actions

    private

    def custom_test
      puts "This comes from ResourcesControllerCustom"
    end

    ### END - Custom methods/actions

  end
end
