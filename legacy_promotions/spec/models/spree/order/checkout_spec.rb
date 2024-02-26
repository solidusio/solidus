# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Order, type: :model do
  let!(:store) { create(:store) }
  let(:order) { create(:order, store: store) }

  context "from delivery", partial_double_verification: false do
    before do
      order.state = 'delivery'
      allow(order).to receive(:apply_shipping_promotions)
      allow(order).to receive(:ensure_available_shipping_rates) { true }
    end

    it "attempts to apply free shipping promotions" do
      expect(order).to receive(:apply_shipping_promotions)
      order.next!
    end
  end
end
