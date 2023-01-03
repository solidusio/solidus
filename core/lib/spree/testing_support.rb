# frozen_string_literal: true

require 'spree/testing_support/factory_bot'

module Spree
  module TestingSupport
    autoload :FactoryBot, "spree/testing_support/factory_bot"

    autoload :SEQUENCES, "spree/testing_support/factory_bot"
    autoload :FACTORIES, "spree/testing_support/factory_bot"

    def factory_bot_paths
      Spree::TestingSupport::FactoryBot.definition_file_paths
    end

    def check_factory_bot_version
      Spree::TestingSupport::FactoryBot.check_version
    end

    def load_all_factories
      Spree::TestingSupport::FactoryBot.add_paths_and_load!
    end

    deprecate(
      factory_bot_paths: "Spree::TestingSupport::FactoryBot.definition_file_paths",
      check_factory_bot_version: "Spree::TestingSupport::FactoryBot.check_version",
      load_all_factories: "Spree::TestingSupport::FactoryBot.add_paths_and_load!",
      deprecator: Spree::Deprecation
    )
  end
end

