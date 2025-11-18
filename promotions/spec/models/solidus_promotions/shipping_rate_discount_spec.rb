# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::ShippingRateDiscount do
  subject(:shipping_rate_discount) { build(:solidus_shipping_rate_discount) }

  it { is_expected.to belong_to(:shipping_rate) }

  it { is_expected.to respond_to(:shipping_rate) }
  it { is_expected.to respond_to(:benefit) }
  it { is_expected.to respond_to(:amount) }
  it { is_expected.to respond_to(:display_amount) }
  it { is_expected.to respond_to(:label) }

  describe "autosaving when order is saved" do
    let(:promotion) { create(:solidus_promotion, :with_free_shipping) }
    let(:benefit) { promotion.benefits.first }
    let(:shipping_rate) { create(:shipping_rate) }
    let(:shipment) { shipping_rate.shipment }

    it "works" do
      shipping_rate.discounts.new(
        amount: -2,
        benefit: benefit,
        label: "Free Shipping"
      )
      expect { shipment.save! }.to change { SolidusPromotions::ShippingRateDiscount.count }
    end
  end
end
