# frozen_string_literal: true

require 'rails_helper'

module Spree
  module Stock
    RSpec.describe AvailabilityValidator do
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
          subject
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

        context "has stock in one stock location" do
          let(:line_item)         { order.line_items.first }

          before do
            line_item.variant.stock_items.update_all(count_on_hand: 10, backorderable: false)
          end

          include_examples "passes validation"
        end

        context "with stock in multiple locations" do
          let(:line_item)         { order.line_items.first }
          let(:variant)           { line_item.variant }
          let!(:stock_location_1) { create(:stock_location, name: "Test Warehouse", active: false) }

          before do
            shipment = order.shipments.create(stock_location: stock_location_1)
            order.contents.add(variant, 1, shipment: shipment)
          end

          context "but no stock in either location" do
            before do
              variant.stock_items.update_all(count_on_hand: 0, backorderable: false)
            end
            include_examples "fails validation"
          end

          context "but no stock in one location" do
            before do
              stock_location_1.stock_items.update_all(count_on_hand: 0, backorderable: false)
            end

            include_examples "fails validation"
          end

          context "with enough stock only across locations" do
            before do
              variant.stock_items.update_all(count_on_hand: 1, backorderable: false)
            end
            include_examples "passes validation"
          end

          context "but inventory units are finalized" do
            before do
              order.inventory_units.update_all(pending: false)
            end

            include_examples "passes validation"
          end
        end
      end

      context "line_item is split across two shipments" do
        let!(:order) { create(:order_with_line_items) }
        let(:line_item) { order.line_items.first }
        let(:variant) { line_item.variant }
        let(:stock_location) { order.shipments.first.stock_location }

        before do
          shipment_two = order.shipments.create!(stock_location: order.shipments.first.stock_location)
          order.contents.add(variant, 1, shipment: shipment_two)
          variant.stock_items.first.update_columns(count_on_hand: count_on_hand, backorderable: false)
        end

        context "and there is just enough stock" do
          let(:count_on_hand) { 2 }
          include_examples "passes validation"
        end

        context "and there is not enough stock" do
          let(:count_on_hand) { 1 }
          include_examples "fails validation"
        end

        context "and there is no available stock" do
          let(:count_on_hand) { 0 }
          include_examples "fails validation"
        end
      end
    end
  end
end
