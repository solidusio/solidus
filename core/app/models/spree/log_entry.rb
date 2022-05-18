# frozen_string_literal: true

module Spree
  class LogEntry < Spree::Base
    # Classes used in core that can be present in serialized details
    #
    # Users can add their own classes in
    # `Spree::Config#log_entry_permitted_classes`.
    #
    # @see Spree::AppConfiguration#log_entry_permitted_classes
    CORE_PERMITTED_CLASSES = [
      ActiveMerchant::Billing::Response,
      ActiveSupport::TimeWithZone,
      Time,
      ActiveSupport::TimeZone
    ].freeze

    # Raised when a disallowed class is tried to be loaded
    class DisallowedClass < RuntimeError
      attr_reader :psych_exception

      def initialize(psych_exception:)
        @psych_exception = psych_exception
        super(default_message)
      end

      private

      def default_message
        <<~MSG
          #{psych_exception.message}

          You can specify custom classes to be loaded in config/initializers/spree.rb. E.g:

          Spree.config do |config|
            config.log_entry_permitted_classes = ['MyClass']
          end
        MSG
      end
    end

    # Raised when YAML contains aliases and they're not enabled
    class BadAlias < RuntimeError
      attr_reader :psych_exception

      def initialize(psych_exception:)
        @psych_exception = psych_exception
        super(default_message)
      end

      private

      def default_message
        <<~MSG
          #{psych_exception.message}

          You can explicitly enable aliases in config/initializers/spree.rb. E.g:

          Spree.config do |config|
            config.log_entry_allow_aliases = true
          end
        MSG
      end
    end

    def self.permitted_classes
      CORE_PERMITTED_CLASSES + Spree::Config.log_entry_permitted_classes.map(&:constantize)
    end

    belongs_to :source, polymorphic: true, optional: true

    def parsed_details
      @details ||= YAML.safe_load(
        details,
        permitted_classes: self.class.permitted_classes,
        aliases: Spree::Config.log_entry_allow_aliases
      )
    rescue Psych::DisallowedClass => e
      raise DisallowedClass.new(psych_exception: e)
    rescue Psych::BadAlias => e
      raise BadAlias.new(psych_exception: e)
    end
  end
end
