# frozen_string_literal: true

require "rails_helper"

module Spree
  module Stock
    RSpec.describe Quantifier, type: :model do
      shared_examples_for "unlimited supply" do
        it "can_supply? any amount" do
          expect(subject.can_supply?(1)).to eq true
          expect(subject.can_supply?(101)).to eq true
          expect(subject.can_supply?(100_001)).to eq true
        end
      end

      shared_examples_for "returns the positive stock on hand" do
        context "when the stock location has no stock for the variant" do
          it { is_expected.to be_zero }
        end

        context "when the stock location has negative stock for the variant" do
          before { stock_item.set_count_on_hand(-1) }

          it { is_expected.to be_zero }
        end

        context "when the stock location has positive stock for the variant" do
          before { stock_item.set_count_on_hand(10) }

          it { is_expected.to eq(10) }
        end
      end

      let(:target_stock_location) { nil }
      let!(:stock_location) { create :stock_location_with_items }
      let!(:stock_item) { stock_location.stock_items.order(:id).first }

      subject { described_class.new(stock_item.variant, target_stock_location) }

      specify { expect(subject.stock_items).to eq([stock_item]) }

      context "with a single stock location/item" do
        it "total_on_hand should match stock_item" do
          expect(subject.total_on_hand).to eq stock_item.count_on_hand
        end

        context "when track_inventory_levels is false" do
          before { stub_spree_preferences(track_inventory_levels: false) }

          specify { expect(subject.total_on_hand).to eq(Float::INFINITY) }

          it_should_behave_like "unlimited supply"
        end

        context "when variant inventory tracking is off" do
          before { stock_item.variant.track_inventory = false }

          specify { expect(subject.total_on_hand).to eq(Float::INFINITY) }

          it_should_behave_like "unlimited supply"
        end

        context "when stock item allows backordering" do
          specify { expect(subject.backorderable?).to be true }

          it_should_behave_like "unlimited supply"
        end

        context "when stock item prevents backordering" do
          before { stock_item.update(backorderable: false) }

          specify { expect(subject.backorderable?).to be false }

          it "can_supply? only upto total_on_hand" do
            expect(subject.can_supply?(1)).to be true
            expect(subject.can_supply?(10)).to be true
            expect(subject.can_supply?(11)).to be false
          end
        end
      end

      context "with multiple stock locations/items" do
        let!(:stock_location_2) { create :stock_location }
        let!(:stock_location_3) { create :stock_location, active: false }

        before do
          stock_location_2.stock_items.where(variant_id: stock_item.variant).update_all(count_on_hand: 5, backorderable: false)
          stock_location_3.stock_items.where(variant_id: stock_item.variant).update_all(count_on_hand: 5, backorderable: false)
        end

        it "total_on_hand should total all active stock_items" do
          expect(subject.total_on_hand).to eq(15)
        end

        context "when any stock item allows backordering" do
          specify { expect(subject.backorderable?).to be true }

          it_should_behave_like "unlimited supply"
        end

        context "when all stock items prevent backordering" do
          before { stock_item.update(backorderable: false) }

          specify { expect(subject.backorderable?).to be false }

          it "can_supply? upto total_on_hand" do
            expect(subject.can_supply?(1)).to be true
            expect(subject.can_supply?(15)).to be true
            expect(subject.can_supply?(16)).to be false
          end
        end
      end

      context "with a specific stock location" do
        let!(:stock_location_2) { create :stock_location }
        let!(:stock_location_3) { create :stock_location, active: false }
        let(:target_stock_location) { stock_location_3 }

        before do
          Spree::StockItem.update_all(count_on_hand: 0, backorderable: false)
          stock_location_3.stock_items.where(variant_id: stock_item.variant).update_all(count_on_hand: 5, backorderable: false)
        end

        it "can_supply? only upto total_on_hand" do
          expect(subject.can_supply?(5)).to eq true
          expect(subject.can_supply?(6)).to eq false
        end
      end

      describe "#positive_stock" do
        let(:variant) { create(:variant) }
        let(:stock_location) { create(:stock_location) }
        let(:stock_item) { stock_location.set_up_stock_item(variant) }
        let(:instance) { described_class.new(variant, stock_location_or_id) }

        subject { instance.positive_stock }

        context "when stock location is not present" do
          let(:stock_location_or_id) { nil }

          it { is_expected.to be_nil }
        end

        context "when stock_location_id is present" do
          context "when stock_location_id is a stock location" do
            let(:stock_location_or_id) { stock_location }

            it_behaves_like "returns the positive stock on hand"
          end

          context "when stock_location_id is a stock location id" do
            let(:stock_location_or_id) { stock_location.id }

            it_behaves_like "returns the positive stock on hand"
          end
        end
      end
    end
  end
end
