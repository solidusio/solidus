# frozen_string_literal: true

module Spree
  module Core
    module ErrorReporter
      class Default < Spree::Core::ErrorReporter::Base
        class << self
          ##
          # Generic error handling
          # @param error [StandardError] The error you want to handle.
          # @param serverity [Symbol, String] The severity (i.e. debug, info, warn, error, fatal)
          #
          def report(error, severity = :error, metadata = {})
            Spree::Config.logger.send(severity, error)

            # Trigger callback for anyone that wants to execute their own logic
            Spree::Config.on_error_report.call(error, severity, metadata)
          end
        end
      end
    end
  end
end
