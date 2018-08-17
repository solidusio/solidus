module Spree
  module Core
    module ErrorReporter
      class SpreeLogger < Spree::Core::ErrorReporter::Base
        def report(error, severity, metadata)
          Spree::Config.logger.send(severity, error)
        end
      end
    end
  end
end
