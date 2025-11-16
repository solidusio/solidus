# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::Benefits::CreateDiscountedItem do
  it { is_expected.to respond_to(:preferred_variant_id) }

  let!(:benefit) { described_class.new(preferred_variant_id: goodie.id, calculator: hundred_percent, promotion: promotion) }
  let(:hundred_percent) { SolidusPromotions::Calculators::Percent.new(preferred_percent: 100) }
  let(:promotion) { create(:solidus_promotion) }
  let(:goodie) { create(:variant) }

  around do |example|
    SolidusPromotions::PromotionLane.set(current_lane: promotion.lane) do
      example.run
    end
  end

  describe "#can_discount?" do
    let(:benefit) { described_class.new }
    let(:discountable) { Spree::Order.new }

    subject { benefit.can_discount?(discountable) }

    it { is_expected.to be false }

    context "with a line item" do
      let(:discountable) { Spree::LineItem.new }

      it { is_expected.to be false }
    end
  end

  describe "#level", :silence_deprecations do
    subject { described_class.new.level }

    it { is_expected.to be :order }
  end

  describe "#perform" do
    let!(:order) { create(:order_with_line_items) }

    subject { benefit.perform(order) }

    it "creates a line item with a hundred percent discount" do
      expect { subject }.to change { order.line_items.size }.by(1)
      created_item = order.line_items.detect { |line_item| line_item.managed_by_order_benefit == benefit }
      # We need to check the item's total_before_tax, because `discountable_amount` would
      # ignore adjustments from the current promotion lane.
      expect(created_item.total_before_tax).to be_zero
    end

    it "never calls the order recalculator" do
      expect(order).not_to receive(:recalculate)
    end

    it "does not persist changes to order" do
      expect {
        subject
      }.not_to make_database_queries(manipulative: true)
    end
  end

  describe "remove_from" do
    let!(:order) { create(:order_with_line_items) }

    subject { benefit.remove_from(order) }

    context "with an item not on the order" do
      it "does not modify the order" do
        expect {
          subject
        }.not_to make_database_queries(manipulative: true)
      end
    end

    context "with an item present on the order" do
      before do
        benefit.perform(order)
        order.save!
      end

      it "marks the the line item for destruction" do
        expect { subject }.to change {
          order.line_items.select(&:marked_for_destruction?).count
        }.by(1)

        expect { order.save }.to change(order.line_items, :count).by(-1)
      end

      it "does not make manipulative database queries" do
        expect {
          subject
        }.not_to make_database_queries(manipulative: true)
      end
    end
  end
end
