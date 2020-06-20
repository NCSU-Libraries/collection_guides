require 'active_support/concern'

module ArchivalObjectsControllerCustom
  extend ActiveSupport::Concern

  included do

    ### BEGIN - Custom methods/actions

    private

    def custom_test
      puts "Hello from ArchivalObjectsControllerCustom"
    end

    ### END - Custom methods/actions

  end
end
