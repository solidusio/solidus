require 'spec_helper'

module Spree
  RSpec.describe ShippingRateTax, type: :model do
    subject(:shipping_rate_tax) { described_class.new }

    it { is_expected.to respond_to(:amount) }
    it { is_expected.to respond_to(:tax_rate) }
    it { is_expected.to respond_to(:shipping_rate) }
  end
end
