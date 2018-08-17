# frozen_string_literal: true

module Spree
  module Core
    module ErrorReporter
      extend self

      def report(error, severity = :error, metadata = {})
        reporters.each do |reporter|
          reporter.report(error, severity, metadata)
        end

        true
      end

      ##
      # All registered reporters
      # @return [Array<ErrorReporter::Base]
      #
      def reporters
        @reporters ||= []
      end

      ##
      # Add a reporter
      # @param reporter_class [ErrorReporter::Base]
      # @return [Array<ErrorReporter::Base>]
      #
      def add_reporter(reporter_class)
        unless reporter_class < Spree::Core::ErrorReporter::Base
          raise ArgumentError, 'Reporter is not type Spree::Core::ErrorReporter::Base'
        end

        reporters << reporter_class
      end

      ##
      # Remove a reporter
      # @param reporter_class [ErrorReporter::Base]
      # @return [Nilclass, ErrorReporter::Base]
      #
      def remove_reporter(reporter_class)
        reporters.delete(reporter_class)
      end

      ##
      # Register Reporters
      #
      add_reporter Spree::Core::ErrorReporter::SpreeLogger
    end
  end
end
