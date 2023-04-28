# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
require 'spree/deprecation'

Spree::Deprecation.warn <<-WARN
  Using `require 'spree/testing_support'` is deprecated and will be removed in
  Solidus 4.0.
WARN

module Spree
  module TestingSupport
    autoload :FactoryBot, "spree/testing_support/factory_bot"
    autoload :SEQUENCES, "spree/testing_support/factory_bot"
    autoload :FACTORIES, "spree/testing_support/factory_bot"

    def check_factory_bot_version
      Spree::TestingSupport::FactoryBot.check_version
    end
    deprecate :check_factory_bot_version, deprecator: Spree::Deprecation
  end
end
