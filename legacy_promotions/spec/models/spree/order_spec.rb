# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Order do
  let(:order) { create(:order) }

  context "#apply_shipping_promotions" do
    it "calls out to the Shipping promotion handler" do
      expect_any_instance_of(Spree::PromotionHandler::Shipping).to(
        receive(:activate)
      ).and_call_original

      expect(order.recalculator).to receive(:recalculate).and_call_original

      order.apply_shipping_promotions
    end
  end
end
