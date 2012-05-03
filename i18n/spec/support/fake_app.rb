require 'spork'

module SpreeI18n
  module Spec
    module FakeApp
      # Initialize Rails app in a clean environment.
      # @param tests [Proc] which have to be run after app was initialized
      # @return [Array, Object] single result if one test was passed given,
      #   otherwise returns an array of results
      def self.run(*tests)
        forker = Spork::Forker.new do
          require 'spree_i18n'
          require 'action_controller/railtie'

          app = Class.new(Rails::Application)
          app.config.active_support.deprecation = :log
          app.config.paths.add "config/database", :with => "spec/support/database.yml"

          yield(app.config) if block_given?
          app.initialize!

          results = tests.map &:call
          results.size == 1 ? results.first : results
        end
        forker.result
      end
    end
  end
end
