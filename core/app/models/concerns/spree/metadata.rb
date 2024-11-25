# frozen_string_literal: true

module Spree
  module Metadata
    extend ActiveSupport::Concern

    included do
      store :public_metadata, coder: JSON
      store :private_metadata, coder: JSON

      validate :validate_metadata_limits
    end

    private

    def validate_metadata_limits
      %i[public_metadata private_metadata].each { |column| validate_metadata_column(column) }
    end

    def validate_metadata_column(column)
      config = Spree::Config
      metadata = send(column)

      # Check for maximum number of keys
      validate_metadata_keys_count(metadata, column, config.max_keys)

      # Check for maximum key and value size
      metadata.each do |key, value|
        validate_metadata_key(key, column, config.max_key_length)
        validate_metadata_value(key, value, column, config.max_value_length)
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
