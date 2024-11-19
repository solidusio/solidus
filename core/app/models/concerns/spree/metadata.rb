# frozen_string_literal: true

module Spree
  module Metadata
    extend ActiveSupport::Concern

    MAX_KEYS = 6
    MAX_KEY_LENGTH = 16
    MAX_VALUE_LENGTH = 256

    included do
      store :public_metadata, coder: JSON
      store :private_metadata, coder: JSON

      validate :validate_metadata_limits
    end

    private

    def validate_metadata_limits
      %i[public_metadata private_metadata].each do |column|
        metadata = send(column)

        # Check for maximum number of keys
        if metadata.keys.count > MAX_KEYS
          errors.add(column, "must not have more than #{MAX_KEYS} keys")
        end

        # Check for maximum key and value size
        metadata.each do |key, value|
          if key.to_s.length > MAX_KEY_LENGTH
            errors.add(column, "key '#{key}' exceeds #{MAX_KEY_LENGTH} characters")
          end

          if value.to_s.length > MAX_VALUE_LENGTH
            errors.add(column, "value for key '#{key}' exceeds #{MAX_VALUE_LENGTH} characters")
          end
        end
      end
    end
  end
end
