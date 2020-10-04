# frozen_string_literal: true

require 'rails_helper'
require 'spree/encryptor'

RSpec.describe Spree::Encryptor do
  let(:key) { 'p3s6v9y$B?E(H+MbQeThWmZq4t7w!z%C' }
  let(:value) { 'payment_system_sdk_id' }

  describe '#encrypt' do
    it 'returns the encrypted value' do
      encryptor = described_class.new(key)
      expect(encryptor.encrypt(value)).not_to eq(value)
    end
  end

  describe '#decrypt' do
    it 'returns the original decrypted value' do
      encryptor = described_class.new(key)
      encrypted_value = encryptor.encrypt(value)

      expect(encryptor.decrypt(encrypted_value)).to eq(value)
    end
  end
end
