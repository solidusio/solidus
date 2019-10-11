# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solidus::Gateway::BogusSimple do
  it 'is deprecated' do
    expect(Solidus::Deprecation).to receive(:warn)
    described_class.new
  end

  it 'has Solidus::PaymentMethod::SimpleBogusCreditCard as superclass' do
    expect(described_class.ancestors).to include(Solidus::PaymentMethod::SimpleBogusCreditCard)
  end
end
