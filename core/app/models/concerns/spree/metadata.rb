# frozen_string_literal: true

module Spree
  module Metadata
    extend ActiveSupport::Concern

    included do
      attribute :customer_metadata, :json, default: {}
      attribute :admin_metadata, :json, default: {}

      validate :validate_metadata_limits, if: :validate_metadata_enabled?
    end

    class_methods do
      def meta_data_columns
        %i[customer_metadata admin_metadata]
      end
    end

    private

    def validate_metadata_enabled?
      Spree::Config.meta_data_validation_enabled
    end

    def validate_metadata_limits
      self.class.meta_data_columns.each { |column| validate_metadata_column(column) }
    end

    def validate_metadata_column(column)
      config = Spree::Config
      metadata = send(column)

      return if metadata.nil?

      # Check for maximum number of keys
      validate_metadata_keys_count(metadata, column, config.meta_data_max_keys)

      # Check for maximum key and value size
      metadata.each do |key, value|
        validate_metadata_key(key, column, config.meta_data_max_key_length)
        validate_metadata_value(key, value, column, config.meta_data_max_value_length)
      end
    end

    def validate_metadata_keys_count(metadata, column, max_keys)
      return unless metadata.keys.count > max_keys

      errors.add(column, "must not have more than #{max_keys} keys")
    end

    def validate_metadata_key(key, column, max_key_length)
      return unless key.to_s.length > max_key_length

      errors.add(column, "key '#{key}' exceeds #{max_key_length} characters")
    end

    def validate_metadata_value(key, value, column, max_value_length)
      return unless value.to_s.length > max_value_length

      errors.add(column, "value for key '#{key}' exceeds #{max_value_length} characters")
    end
  end
end
