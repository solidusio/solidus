# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe CheckoutHelper, type: :helper do
  describe '#partial_name_with_fallback' do
    it "uses the partial_name if it exists" do
      expect(
        partial_name_with_fallback('orders/payment_info', 'gateway', 'default')
      ).to eq('orders/payment_info/gateway')
    end

    it "uses the fallback_name if it's missing" do
      expect(
        partial_name_with_fallback('orders/payment_info', 'foo', 'default')
      ).to eq('orders/payment_info/default')
    end
  end
end
