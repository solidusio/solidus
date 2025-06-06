# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Price do
  it { is_expected.to respond_to(:discountable_amount) }
  it { is_expected.to respond_to(:current_discounts) }
  it { is_expected.to respond_to(:discounted_amount) }
  it { is_expected.to respond_to(:discounts) }

  context "with a discount" do
    let(:price) { build(:price, current_discounts: [discount]) }
    let(:discount) { SolidusPromotions::ItemDiscount.new(amount: -5, label: "Promo label") }

    it "does all the right things" do
      expect(price.amount).to eq(19.99)
      expect(price.discounted_amount).to eq(14.99)
      expect(price.display_discounted_amount.to_s).to eq("$14.99")
      expect(price.discounts).to include(discount)
    end
  end
end
