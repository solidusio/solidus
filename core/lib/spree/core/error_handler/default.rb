module Spree
  module Core
    module ErrorHandler
      class Default < Spree::Core::ErrorHandler::Base
        class << self
          ##
          # Generic error handling
          # @param error [StandardError] The error you want to handle.
          # @param serverity [Symbol, String] The severity (i.e. debug, info, warn, error, fatal)
          #
          def handle(error, severity: :error)
            Spree::Config.logger.send(severity, error)
          end
        end
      end
    end
  end
end
