require 'active_support/concern'

module ArchivalObjectCustom
  extend ActiveSupport::Concern

  included do

    def custom_test
      puts "This comes from ArchivalObjectCustom"
    end

  end
end
