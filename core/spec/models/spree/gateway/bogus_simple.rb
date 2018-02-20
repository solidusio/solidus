# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Gateway::BogusSimple do
  it 'is deprecated' do
    expect(Spree::Deprecation).to receive(:warn)
    described_class.new
  end

  it 'has Spree::PaymentMethod::SimpleBogusCreditCard as superclass' do
    expect(described_class.ancestors).to include(Spree::PaymentMethod::SimpleBogusCreditCard)
  end
end
