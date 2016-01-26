require 'spec_helper'

module Spree
  module Stock
    describe AvailabilityValidator do
      let(:validator) { Spree::Stock::AvailabilityValidator.new }

      subject { validator.validate(line_item) }

      shared_examples_for "fails validation" do
        it "returns false" do
          expect(subject).to eq false
        end

        it "adds a validation error" do
          subject
          display_name = line_item.variant.name.to_s
          display_name += " (#{line_item.variant.options_text})" unless line_item.variant.options_text.blank?
          expect(line_item.errors).to match_array ["Quantity selected of #{display_name.inspect} is not available."]
        end
      end

      shared_examples_for "passes validation" do
        it "returns true" do
          expect(subject).to eq true
        end

        it "doesn't add a validation error" do
          expect(line_item.errors).to be_empty
        end
      end

      context "line_item is not part of a shipment" do
        let(:line_item) { create(:line_item) }

        context "has stock in all stock locations" do
          before do
            Spree::StockItem.where(variant_id: line_item.variant_id).update_all(count_on_hand: 10, backorderable: false)
          end

          include_examples "passes validation"
        end

        context "doesn't have stock in any stock location" do
          before do
            Spree::StockItem.where(variant_id: line_item.variant_id).update_all(count_on_hand: 0, backorderable: false)
          end

          include_examples "fails validation"
        end
      end

      context "line_item is part of a shipment" do
        let!(:order) { create(:order_with_line_items) }

        context "has stock in all stock locations" do
          let(:line_item)         { order.line_items.first }

          before do
            variant_ids = order.line_items.map(&:variant_id)
            Spree::StockItem.where(variant_id: variant_ids).update_all(count_on_hand: 10, backorderable: false)
          end

          include_examples "passes validation"
        end

        context "doesn't have stock in a particular stock location" do
          let(:variant)           { create(:variant) }
          let(:line_item)         { order.line_items.find_by(variant_id: variant.id) }
          let!(:stock_location_1) { create(:stock_location, name: "Test Warehouse", active: false) }

          before do
            order.contents.add(variant, 1, stock_location_quantities: { stock_location_1.id => 1 })
            order.contents.advance
            stock_location_1.stock_items.update_all(count_on_hand: 0, backorderable: false)
          end

          include_examples "fails validation"
        end
      end
    end
  end
end
