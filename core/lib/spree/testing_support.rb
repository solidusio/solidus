# frozen_string_literal: true

require 'spree/testing_support/factory_bot'

module Spree
  module TestingSupport
    autoload :FactoryBot, "spree/testing_support/factory_bot"
    autoload :SEQUENCES, "spree/testing_support/factory_bot"
    autoload :FACTORIES, "spree/testing_support/factory_bot"

    def check_factory_bot_version
      Spree::TestingSupport::FactoryBot.check_version
    end
  end
end
