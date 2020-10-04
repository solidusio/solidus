# frozen_string_literal: true

require 'rails_helper'

module Spree::Stock
  RSpec.describe Availability do
    let(:variants) { Spree::Variant.all.to_a }
    let(:infinity) { Float::INFINITY }

    let(:availability) { described_class.new(variants: variants) }

    let!(:stock_location1) { create(:stock_location) }

    subject { availability }

    describe "#on_hand_by_stock_location_id" do
      subject { availability.on_hand_by_stock_location_id }

      context 'with a single variant' do
        let!(:variant) { create(:master_variant) }
        let(:stock_item) { variant.stock_items[0] }

        context 'with count_on_hand positive' do
          before { stock_item.set_count_on_hand(2) }

          it "returns the correct value" do
            expect(subject).to eq(stock_location1.id => Spree::StockQuantities.new(variant => 2))
          end

          context 'and backorderable false' do
            before { stock_item.update!(backorderable: false) }

            it "returns the correct value" do
              expect(subject).to eq(stock_location1.id => Spree::StockQuantities.new(variant => 2))
            end
          end
        end

        context 'with count_on_hand 0' do
          before { stock_item.set_count_on_hand(0) }

          it "returns zero on_hand" do
            expect(subject).to eq(stock_location1.id => Spree::StockQuantities.new(variant => 0))
          end
        end

        context 'with count_on_hand negative' do
          before { stock_item.set_count_on_hand(-1) }

          it "returns zero on_hand" do
            expect(subject).to eq(stock_location1.id => Spree::StockQuantities.new(variant => 0))
          end
        end

        context 'with no stock_item' do
          before { stock_item.really_destroy! }

          it "returns empty hash" do
            expect(subject).to eq({})
          end
        end

        context 'with soft-deleted stock_item' do
          before { stock_item.discard }

          it "returns empty hash" do
            expect(subject).to eq({})
          end
        end

        context 'with track_inventory=false' do
          before { variant.update!(track_inventory: false) }

          it "has infinite inventory " do
            expect(subject).to eq(stock_location1.id => Spree::StockQuantities.new(variant => infinity))
          end
        end

        context 'with config.track_inventory_levels=false' do
          before { stub_spree_preferences(track_inventory_levels: false) }

          it "has infinite inventory " do
            expect(subject).to eq(stock_location1.id => Spree::StockQuantities.new(variant => infinity))
          end
        end
      end
    end

    describe "#backorderable_by_stock_location_id" do
      subject { availability.backorderable_by_stock_location_id }

      context 'with a single variant' do
        let!(:variant) { create(:master_variant) }
        let(:stock_item) { variant.stock_items[0] }

        context 'with backorderable false' do
          before { stock_item.update!(backorderable: false) }

          context 'and positive count_on_hand' do
            before { stock_item.set_count_on_hand(2) }
            it { is_expected.to eq({}) }
          end

          context 'and 0 count_on_hand' do
            before { stock_item.set_count_on_hand(0) }
            it { is_expected.to eq({}) }
          end
        end

        context 'with backorderable true' do
          before { stock_item.update!(backorderable: true) }

          context 'and positive count_on_hand' do
            before { stock_item.set_count_on_hand(2) }
            it { is_expected.to eq(stock_location1.id => Spree::StockQuantities.new(variant => infinity)) }
          end

          context 'and 0 count_on_hand' do
            before { stock_item.set_count_on_hand(0) }
            it { is_expected.to eq(stock_location1.id => Spree::StockQuantities.new(variant => infinity)) }
          end

          context 'and negative count_on_hand' do
            before { stock_item.set_count_on_hand(-1) }
            it { is_expected.to eq(stock_location1.id => Spree::StockQuantities.new(variant => infinity)) }
          end
        end

        context 'with soft-deleted stock_item' do
          before { stock_item.discard }

          it { is_expected.to eq({}) }
        end

        context 'with no stock_item' do
          before { stock_item.really_destroy! }

          it { is_expected.to eq({}) }
        end
      end
    end
  end
end
