# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solidus::Gateway do
  it 'is deprecated' do
    expect(Solidus::Deprecation).to receive(:warn)
    described_class.new
  end

  it 'has Solidus::PaymentMethod::CreditCard as superclass' do
    expect(described_class.ancestors).to include(Solidus::PaymentMethod::CreditCard)
  end
end
