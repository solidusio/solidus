# frozen_string_literal: true

module Spree
  module Core
    module ErrorReporter
      ##
      # Abstract class only meant to be inherited from
      #
      # @example Create a custom error handler
      #   class CustomErrorReporter < Spree::Core::ErrorReporter::Base
      #     # Output to as debug by default
      #     def report(error, severity, metadata)
      #       Rollbar.send(severity, error, metadata)
      #     end
      #   end
      #
      #   Spree::Core::ErrorReporter.add_reporter(CustomErrorReporter)
      #
      class Base
        class << self
          ##
          # Generic error handling
          # @param error [StandardError] The error you want to handle.
          # @param serverity [Symbol, String] The severity (i.e. debug, info, warn, error, fatal)
          # @param metadata [Hash] Any metadata we want to pass in
          #
          def report(_error, _severity = :error, _metadata = {})
            raise NoMethodError
          end
        end
      end
    end
  end
end
