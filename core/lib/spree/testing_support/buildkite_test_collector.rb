# frozen_string_literal: true

require "buildkite/test_collector"

module Spree
  module TestingSupport
    module BuildkiteTestCollector
      def self.enable
        Buildkite::TestCollector.configure(hook: :rspec)
      end
    end
  end
end

