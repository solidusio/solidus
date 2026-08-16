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
      ActiveSupport::HashWithIndifferentAccess,
      Time,
      ActiveSupport::TimeZone,
      Symbol
    ].freeze

    class SerializationError < RuntimeError
      attr_reader :psych_exception

      def initialize(psych_exception:)
        @psych_exception = psych_exception
        super(default_message)
      end
    end

    # Raised when a disallowed class is tried to be loaded
    class DisallowedClass < SerializationError
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
    class BadAlias < SerializationError
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
      # A missing configured class (e.g. a gateway gem dropped a serialized payload class)
      # would otherwise crash every payment view that loads any log entry.
      configured = Spree::Config.log_entry_permitted_classes.filter_map do |class_name|
        class_name.constantize
      rescue NameError
        Rails.logger.warn("Spree::LogEntry: ignoring missing permitted class #{class_name.inspect}")
        nil
      end
      CORE_PERMITTED_CLASSES + configured
    end

    belongs_to :source, polymorphic: true, optional: true

    def parsed_details
      @details ||= deserialize_details
    end

    def parsed_details=(value)
      self.details = YAML.dump(value)
    end

    def parsed_payment_response_details_with_fallback=(response)
      self.parsed_details = response
    end

    private

    def deserialize_details
      handle_psych_serialization_errors do
        YAML.safe_load(
          details,
          permitted_classes: self.class.permitted_classes,
          aliases: Spree::Config.log_entry_allow_aliases
        )
      end
    rescue SerializationError, Psych::Exception => e
      # The stored response could not be deserialized (a class that isn't
      # permitted, a disabled alias, or malformed YAML). Keep the record readable
      # by wrapping the raw details and surfacing the reason instead of raising,
      # while reporting the error so it stays visible to developers.
      Rails.error.report(e, handled: true, severity: :warning, context: {spree_log_entry_id: id})
      ActiveMerchant::Billing::Response.new(
        false,
        "[WARNING: An error occurred while trying to deserialize the stored payment response] #{e.message}",
        {"data" => details, "error" => e.message}
      )
    end

    def handle_psych_serialization_errors
      yield
    rescue Psych::DisallowedClass => e
      raise DisallowedClass.new(psych_exception: e)
    rescue Psych::BadAlias => e
      raise BadAlias.new(psych_exception: e)
    end
  end
end
