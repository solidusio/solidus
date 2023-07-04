# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::Action do
  it { is_expected.to belong_to(:promotion) }
  it { is_expected.to have_one(:calculator) }

  it { is_expected.to respond_to :adjust }
  it { is_expected.to respond_to :can_adjust? }

  describe "#can_adjust?" do
    subject { described_class.new.can_adjust?(double) }

    it "raises a NotImplementedError" do
      expect { subject }.to raise_exception(NotImplementedError)
    end
  end

  describe "#adjust" do
    let(:variant) { create(:variant) }
    let(:order) { create(:order) }
    let(:adjustable) { Spree::LineItem.new(order: order, variant: variant, price: 10)}
    let(:promotion) { Spree::Promotion.new(name: "20 Perzent off") }
    let(:action) { described_class.new(promotion: promotion)}
    before do
      allow(action).to receive(:compute_amount).and_return(-1)
    end

    subject { action.adjust(adjustable) }

    it "adds an adjustment to the adjustable" do
      expect { subject }.to change { adjustable.adjustments.length }.by(1)
      expect(adjustable.adjustments.first.label).to eq("Promotion (20 Perzent off)")
    end
  end
end
