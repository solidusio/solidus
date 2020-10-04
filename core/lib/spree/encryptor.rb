# frozen_string_literal: true

module Spree
  # Spree::Encryptor is a thin wrapper around ActiveSupport::MessageEncryptor.
  class Encryptor
    # @param key [String] the 256 bits signature key
    def initialize(key)
      @crypt = ActiveSupport::MessageEncryptor.new(key)
    end

    # Encrypt a value
    # @param value [String] the value to encrypt
    # @return [String] the encrypted value
    def encrypt(value)
      @crypt.encrypt_and_sign(value)
    end

    # Decrypt an encrypted value
    # @param encrypted_value [String] the value to decrypt
    # @return [String] the decrypted value
    def decrypt(encrypted_value)
      @crypt.decrypt_and_verify(encrypted_value)
    end
  end
end
