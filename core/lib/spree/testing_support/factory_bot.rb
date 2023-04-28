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

      def self.check_version
        require "factory_bot/version"

        requirement = Gem::Requirement.new(">= 4.8")
        version = Gem::Version.new(::FactoryBot::VERSION)

        unless requirement.satisfied_by? version
          raise <<~MSG
            Please be aware that the supported version of FactoryBot is #{requirement},
            using version #{version} could lead to factory loading issues.
          MSG
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
