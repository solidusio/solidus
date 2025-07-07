# frozen_string_literal: true

module Spree
  module TestingSupport
    module JobHelpers
      def self.included(base)
        Spree.deprecator.warn <<~WARN
          Including `Spree::TestingSupport::JobHelpers` is deprecated and will be removed in Solidus 5.0.
          Please `include ActiveJob::TestHelper` instead.
        WARN
        base.include(ActiveJob::TestHelper)
      end
    end
  end
end
