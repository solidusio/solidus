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

      FactoryBot.definition_file_paths.concat(factory_bot_paths).uniq!
      FactoryBot.reload
    end
  end
end
