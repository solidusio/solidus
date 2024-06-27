# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::OrderAdjuster::ChooseDiscounts do
  subject { described_class.new(discounts).call }

  let(:source_1) { create(:solidus_promotion, :with_adjustable_benefit).benefits.first }
  let(:source_2) { create(:solidus_promotion, :with_adjustable_benefit).benefits.first }
  let(:good_discount) { SolidusPromotions::ItemDiscount.new(amount: -2, source: source_1) }
  let(:bad_discount) { SolidusPromotions::ItemDiscount.new(amount: -1, source: source_2) }

  let(:discounts) do
    [
      good_discount,
      bad_discount
    ]
  end

  it { is_expected.to contain_exactly(good_discount) }
end
