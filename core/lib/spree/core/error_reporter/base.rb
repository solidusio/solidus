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
      #     def handle(error, severity: :debug)
      #       Rollbar.send(severity, error)
      #       Rails.logger.send(severity, error)
      #     end
      #   end
      #
      class Base
        class << self
          ##
          # Generic error handling
          # @param error [StandardError] The error you want to handle.
          # @param serverity [Symbol, String] The severity (i.e. debug, info, warn, error, fatal)
          #
          def report(_error, _severity = :error)
            raise NoMethodError
          end
        end
      end
    end
  end
end
