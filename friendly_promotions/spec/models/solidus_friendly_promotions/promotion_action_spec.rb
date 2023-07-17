# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::PromotionAction do
  it { is_expected.to belong_to(:promotion) }
  it { is_expected.to have_one(:calculator) }

  it { is_expected.to respond_to :discount }
  it { is_expected.to respond_to :can_discount? }

  describe "#can_adjust?" do
    subject { described_class.new.can_discount?(double) }

    it "raises a NotImplementedError" do
      expect { subject }.to raise_exception(NotImplementedError)
    end
  end

  describe "#discount" do
    let(:variant) { create(:variant) }
    let(:order) { create(:order) }
    let(:adjustable) { Spree::LineItem.new(order: order, variant: variant, price: 10)}
    let(:promotion) { SolidusFriendlyPromotions::Promotion.new(name: "20 Perzent off") }
    let(:action) { described_class.new(promotion: promotion)}
    before do
      allow(action).to receive(:compute_amount).and_return(-1)
    end

    subject { action.discount(adjustable) }

    it "returs an discount to the adjustable" do
      expect(subject).to eq(
        SolidusFriendlyPromotions::ItemDiscount.new(
          item: adjustable,
          label: "Promotion (20 Perzent off)",
          source: action,
          amount: -1
        )
      )
    end
  end
end
