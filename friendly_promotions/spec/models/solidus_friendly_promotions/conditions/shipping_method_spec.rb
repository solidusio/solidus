# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::Conditions::ShippingMethod, type: :model do
  let(:condition) { described_class.new }
  let!(:promotion) { create(:friendly_promotion, :with_adjustable_action) }
  let(:promotion_action) { promotion.actions.first }
  let(:ups_ground) { create(:shipping_method) }
  let(:dhl_saver) { create(:shipping_method) }

  it { is_expected.to respond_to(:preferred_shipping_method_ids) }

  describe "preferred_shipping_methods_ids=" do
    subject { condition.preferred_shipping_method_ids = [ups_ground.id] }

    let(:condition) { promotion_action.conditions.build(type: described_class.to_s) }

    it "creates a valid condition with a shipping method" do
      subject
      expect(condition).to be_valid
      expect(condition.preferred_shipping_method_ids).to include(ups_ground.id)
    end
  end

  describe "#eligible?" do
    subject { condition.eligible?(promotable) }

    let(:condition) { promotion_action.conditions.build(type: described_class.to_s, preferred_shipping_method_ids: [ups_ground.id]) }

    context "with a shipment" do
      context "when the shipment has the right shipping method selected" do
        let(:promotable) { create(:shipment, shipping_method: ups_ground) }

        it { is_expected.to be true }
      end

      context "when the shipment does not have the right shipping method selected" do
        let(:promotable) { create(:shipment, shipping_method: dhl_saver) }

        it { is_expected.to be false }
      end

      context "when the shipment has no shipping method selected" do
        let(:promotable) { create(:shipment, shipping_method: nil) }

        it { is_expected.to be false }
      end
    end

    context "with a shipping rate" do
      context "when the shipping rate has the right shipping method selected" do
        let(:promotable) { create(:shipping_rate, shipping_method: ups_ground) }

        it { is_expected.to be true }
      end

      context "when the shipping rate does not have the right shipping method selected" do
        let(:promotable) { create(:shipping_rate, shipping_method: dhl_saver) }

        it { is_expected.to be false }
      end
    end
  end
end
