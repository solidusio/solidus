# frozen_string_literal: true

require "factory_bot"
begin
  require "factory_bot_rails"
rescue LoadError
end

module SolidusLegacyPromotions
  module TestingSupport
    module FactoryBot
      FACTORIES = Dir["#{::SolidusLegacyPromotions::Engine.root}/lib/solidus_legacy_promotions/testing_support/factories/**/*_factory.rb"].sort

      def self.definition_file_paths
        @paths ||= FACTORIES.map { |path| path.sub(/.rb\z/, '') }
      end

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
