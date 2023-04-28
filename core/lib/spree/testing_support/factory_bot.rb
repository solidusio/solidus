# frozen_string_literal: true

require "factory_bot"
begin
  require "factory_bot_rails"
rescue LoadError
end

module Spree
  module TestingSupport
    module FactoryBot
      SEQUENCES = ["#{::Spree::Core::Engine.root}/lib/spree/testing_support/sequences.rb"]
      FACTORIES = Dir["#{::Spree::Core::Engine.root}/lib/spree/testing_support/factories/**/*_factory.rb"].sort
      PATHS = SEQUENCES + FACTORIES

      def self.definition_file_paths
        @paths ||= PATHS.map { |path| path.sub(/.rb\z/, '') }
      end

      def self.when_cherry_picked
        callsites = caller

        # All good if the factory is being loaded by FactoryBot or from `testing_support/factories.rb`.
        return if callsites.find do |line|
          line.include?("/factory_bot/find_definitions.rb") ||
          line.include?("/spree/testing_support/factories.rb")
        end

        yield
      end

      def self.deprecate_cherry_picking
        callsites = caller
        core_root = Spree::Core::Engine.root.to_s
        index = callsites.index { |line| !line.start_with? core_root }

        Spree::Deprecation.warn(
          "Please do not cherry-pick factories, this is not well supported by FactoryBot, " \
          'follow the changelog instructions on how to migrate your current setup.',
          callsites[index..]
        )
      end

      def self.check_version
        require "factory_bot/version"

        requirement = Gem::Requirement.new(">= 4.8")
        version = Gem::Version.new(::FactoryBot::VERSION)

        unless requirement.satisfied_by? version
          Spree::Deprecation.warn(
            "Please be aware that the supported version of FactoryBot is #{requirement}, " \
            "using version #{version} could lead to factory loading issues.", caller(2)
          )
        end
      end
      deprecate :check_version, deprecator: Spree::Deprecation

      def self.add_definitions!
        ::FactoryBot.definition_file_paths.unshift(*definition_file_paths).uniq!
      end

      def self.add_paths_and_load!
        add_definitions!
        ::FactoryBot.reload
      end
    end
  end
end
