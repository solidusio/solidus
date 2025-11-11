# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::Conditions::ShipmentLevelCondition do
  let(:legacy_condition) do
    Class.new(SolidusPromotions::Condition) do
      include SolidusPromotions::Conditions::ShipmentLevelCondition

      def eligible?(_line_item)
        true
      end
    end
  end

  it "emits a warning telling the user to rename eligible? to line_item_eligible?" do
    expect(Spree.deprecator).to receive(:warn).with <<~MSG
      Defining `eligible?` on a promotion along with including the `ShipmentLevelCondition` module is deprecated.
      Rename `eligible?` to `shipment_eligible?` and stop including the `ShipmentLevelCondition` module.
    MSG
    legacy_condition
  end

  it "responds to eligible?", :silence_deprecations do
    expect(legacy_condition.new.eligible?(Spree::Shipment.new)).to be true
  end

  describe "#applicable?", :silence_deprecations do
    it "is applicable for shipments" do
      expect(legacy_condition.new.applicable?(Spree::Shipment.new)).to be true
    end

    it "is not applicable for line items" do
      expect(legacy_condition.new.applicable?(Spree::LineItem.new)).to be false
    end
  end
end
