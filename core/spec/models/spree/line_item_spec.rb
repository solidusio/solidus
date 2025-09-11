# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::LineItem, type: :model do
  let(:order) { create :order_with_line_items, line_items_count: 1 }
  let(:line_item) { order.line_items.first }
  let(:target_shipment) { Spree::Shipment.new }

  context "#destroy" do
    it "fetches soft-deleted products" do
      line_item.product.discard
      expect(line_item.reload.product).to be_a Spree::Product
    end

    it "fetches soft-deleted variants" do
      line_item.variant.discard
      expect(line_item.reload.variant).to be_a Spree::Variant
    end

    it "returns inventory when a line item is destroyed" do
      line_item.target_shipment = target_shipment
      expect_any_instance_of(Spree::OrderInventory).to receive(:verify).with(target_shipment)
      line_item.destroy
    end

    it "deletes inventory units" do
      expect { line_item.destroy }.to change { line_item.inventory_units.count }.from(1).to(0)
    end
  end

  context "#save" do
    context "target_shipment is provided" do
      it "verifies inventory" do
        line_item.target_shipment = target_shipment
        expect_any_instance_of(Spree::OrderInventory).to receive(:verify).with(target_shipment)
        line_item.save
      end
    end
  end

  describe ".new" do
    let(:variant) { create :variant }

    subject(:line_item) { Spree::LineItem.new(variant:, order:) }

    it "copies the variants price" do
      expect(line_item.price).to eq(variant.price)
    end

    it "copies the variants cost_price" do
      expect(line_item.cost_price).to eq(variant.cost_price)
    end

    it "copies the order's currency" do
      expect(line_item.currency).to eq(order.currency)
    end

    it "copies the variants tax category" do
      expect(line_item.tax_category).to eq(line_item.variant.tax_category)
    end
  end

  describe "#total_before_tax" do
    before do
      line_item.update!(price: 10, quantity: 2)
    end
    let!(:admin_adjustment) { create(:adjustment, adjustable: line_item, order: line_item.order, amount: -1, source: nil) }
    let!(:other_adjustment) { create(:adjustment, adjustable: line_item, order: line_item.order, amount: -2, source: nil) }

    it "returns the amount minus any adjustments" do
      expect(line_item.total_before_tax).to eq(20 - 1 - 2)
    end
  end

  describe ".money" do
    before do
      line_item.price = 3.50
      line_item.quantity = 2
    end

    it "returns a Spree::Money representing the total for this line item" do
      expect(line_item.money.to_s).to eq("$7.00")
    end
  end

  describe ".single_money" do
    before { line_item.price = 3.50 }
    it "returns a Spree::Money representing the price for one variant" do
      expect(line_item.single_money.to_s).to eq("$3.50")
    end
  end

  context "setting a line item price" do
    let(:store) { create(:store, default: true) }
    let(:order) { Spree::Order.new(currency: "RUB", store:) }
    let(:variant) { Spree::Variant.new(product: Spree::Product.new) }
    let(:line_item) { Spree::LineItem.new(order:, variant:) }

    before { expect(variant).to receive(:price_for_options).at_least(:once).and_return(price) }

    context "when a price exists in order currency" do
      let(:price) { Spree::Price.new(amount: 99.00, currency: "RUB") }

      it "is a valid line item" do
        expect(line_item.valid?).to be_truthy
        expect(line_item.errors[:price].size).to eq(0)
      end
    end

    context "when a price does not exist in order currency" do
      let(:price) { nil }

      it "is not a valid line item" do
        expect(line_item.valid?).to be_falsey
        expect(line_item.errors[:price].size).to eq(1)
      end
    end
  end

  describe "#options=" do
    let(:options) { {price: 123, quantity: 5} }

    it "updates the data provided in the options" do
      line_item.options = options

      expect(line_item.price).to eq 123
      expect(line_item.quantity).to eq 5
    end

    context "when price is not provided" do
      let(:options) { {quantity: 5} }

      it "sets price anyway, retrieving it from line item options" do
        expect(line_item.variant)
          .to receive(:price_for_options)
          .and_return(Spree::Price.new(amount: 123, currency: "USD"))

        line_item.options = options

        expect(line_item.price).to eq 123
        expect(line_item.quantity).to eq 5
      end
    end
  end

  describe "money_price=" do
    let(:currency) { "USD" }
    let(:new_price) { Spree::Money.new(99.00, currency:) }

    it "assigns a new price" do
      line_item.money_price = new_price
      expect(line_item.price).to eq(new_price.cents / 100.0)
    end

    context "when the new price is nil" do
      let(:new_price) { nil }

      it "makes the line item price empty" do
        line_item.money_price = new_price
        expect(line_item.price).to be_nil
      end
    end

    context "when the price has a currency different from the order currency" do
      let(:currency) { "RUB" }

      it "is not valid" do
        line_item.money_price = new_price
        expect(line_item).not_to be_valid
        expect(line_item.errors[:price])
          .to include "Line item price currency must match order currency!"
      end
    end
  end

  describe "#pricing_options" do
    subject { line_item.pricing_options }

    it { is_expected.to be_a(Spree::Config.pricing_options_class) }

    it "holds the order currency" do
      expect(subject.currency).to eq("USD")
    end
  end

  it_behaves_like "customer and admin metadata fields: storage and validation", :line_item
end
