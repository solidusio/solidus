# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Order do
  subject { described_class.new }
  it { is_expected.to respond_to(:order_promotions) }
  it { is_expected.to respond_to(:promotions) }

  context "#apply_shipping_promotions" do
    let(:order) { build(:order) }

    it "calls out to the Shipping promotion handler" do
      expect_any_instance_of(Spree::PromotionHandler::Shipping).to(
        receive(:activate)
      ).and_call_original

      expect(order.recalculator).to receive(:recalculate).and_call_original

      order.apply_shipping_promotions
    end
  end

  describe "order deletion" do
    let(:order) { create(:order) }
    let(:promotion) { create(:promotion) }

    subject { order.destroy }
    before do
      order.promotions << promotion
    end

    it "deletes join table entries when deleting an order" do
      expect { subject }.to change { Spree::OrderPromotion.count }.from(1).to(0)
    end
  end
end
