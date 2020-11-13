# frozen_string_literal: true

module Spree
  module TestingSupport
    SEQUENCES = ["#{::Spree::Core::Engine.root}/lib/spree/testing_support/sequences.rb"]
    FACTORIES = Dir["#{::Spree::Core::Engine.root}/lib/spree/testing_support/factories/**/*_factory.rb"]

    def self.factory_bot_paths
      @paths ||= (SEQUENCES + FACTORIES).sort.map { |path| path.sub(/.rb\z/, '') }
    end

    def self.load_all_factories
      require 'factory_bot'
      require 'factory_bot/version'

      requirement = Gem::Requirement.new("~> 4.8")
      version = Gem::Version.new(FactoryBot::VERSION)

      unless requirement.satisfied_by? version
        Spree::Deprecation.warn(
          "Please be aware that the supported version of FactoryBot is #{requirement}, " \
          "using version #{version} could lead to factory loading issues.", caller(2)
        )
      end

      FactoryBot.definition_file_paths.concat(factory_bot_paths).uniq!
      FactoryBot.reload
    end
  end
end
