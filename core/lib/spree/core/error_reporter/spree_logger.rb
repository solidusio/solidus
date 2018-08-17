# frozen_string_literal: true

module Spree
  module Core
    module ErrorReporter
      class SpreeLogger < Spree::Core::ErrorReporter::Base
        def self.report(error, severity, _metadata)
          Spree::Config.logger.send(severity, error)
        end
      end
    end
  end
end
