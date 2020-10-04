# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::StockItem, type: :model do
  let(:stock_location) { create(:stock_location_with_items) }

  subject { stock_location.stock_items.order(:id).first }

  it 'maintains the count on hand for a variant' do
    expect(subject.count_on_hand).to eq 10
  end

  it "can return the stock item's variant's name" do
    expect(subject.variant_name).to eq(subject.variant.name)
  end

  context "available to be included in shipment" do
    context "has stock" do
      it { expect(subject).to be_available }
    end

    context "backorderable" do
      before { subject.backorderable = true }
      it { expect(subject).to be_available }
    end

    context "no stock and not backorderable" do
      before do
        subject.backorderable = false
        allow(subject).to receive_messages(count_on_hand: 0)
      end

      it { expect(subject).not_to be_available }
    end
  end

  describe 'reduce_count_on_hand_to_zero' do
    context 'when count_on_hand > 0' do
      before(:each) do
        subject.update_column('count_on_hand', 4)
        subject.reduce_count_on_hand_to_zero
      end

      it { expect(subject.count_on_hand).to eq(0) }
    end

    context 'when count_on_hand > 0' do
      before(:each) do
        subject.update_column('count_on_hand', -4)
        @count_on_hand = subject.count_on_hand
        subject.reduce_count_on_hand_to_zero
      end

      it { expect(subject.count_on_hand).to eq(@count_on_hand) }
    end
  end

  context "adjust count_on_hand" do
    let!(:current_on_hand) { subject.count_on_hand }

    it 'is updated pessimistically' do
      copy = Spree::StockItem.find(subject.id)

      subject.adjust_count_on_hand(5)
      expect(subject.count_on_hand).to eq(current_on_hand + 5)

      expect(copy.count_on_hand).to eq(current_on_hand)
      copy.adjust_count_on_hand(5)
      expect(copy.count_on_hand).to eq(current_on_hand + 10)
    end

    context "item out of stock (by two items)" do
      let(:inventory_unit) { double('InventoryUnit') }
      let(:inventory_unit_2) { double('InventoryUnit2') }

      before do
        allow(subject).to receive_messages(backordered_inventory_units: [inventory_unit, inventory_unit_2])
        subject.update_column(:count_on_hand, -2)
      end

      # Regression test for https://github.com/spree/spree/issues/3755
      it "processes existing backorders, even with negative stock" do
        expect(inventory_unit).to receive(:fill_backorder)
        expect(inventory_unit_2).not_to receive(:fill_backorder)
        subject.adjust_count_on_hand(1)
        expect(subject.count_on_hand).to eq(-1)
      end

      # Test for https://github.com/spree/spree/issues/3755
      it "does not process backorders when stock is adjusted negatively" do
        expect(inventory_unit).not_to receive(:fill_backorder)
        expect(inventory_unit_2).not_to receive(:fill_backorder)
        subject.adjust_count_on_hand(-1)
        expect(subject.count_on_hand).to eq(-3)
      end

      context "adds new items" do
        before { allow(subject).to receive_messages(backordered_inventory_units: [inventory_unit, inventory_unit_2]) }

        it "fills existing backorders" do
          expect(inventory_unit).to receive(:fill_backorder)
          expect(inventory_unit_2).to receive(:fill_backorder)

          subject.adjust_count_on_hand(3)
          expect(subject.count_on_hand).to eq(1)
        end
      end
    end
  end

  context "set count_on_hand" do
    let!(:current_on_hand) { subject.count_on_hand }

    it 'is updated pessimistically' do
      copy = Spree::StockItem.find(subject.id)

      subject.set_count_on_hand(5)
      expect(subject.count_on_hand).to eq(5)

      expect(copy.count_on_hand).to eq(current_on_hand)
      copy.set_count_on_hand(10)
      expect(copy.count_on_hand).to eq(current_on_hand)
    end

    context "item out of stock (by two items)" do
      let(:inventory_unit) { double('InventoryUnit') }
      let(:inventory_unit_2) { double('InventoryUnit2') }

      before { subject.set_count_on_hand(-2) }

      it "doesn't process backorders" do
        expect(subject).not_to receive(:backordered_inventory_units)
      end

      context "adds new items" do
        before { allow(subject).to receive_messages(backordered_inventory_units: [inventory_unit, inventory_unit_2]) }

        it "fills existing backorders" do
          expect(inventory_unit).to receive(:fill_backorder)
          expect(inventory_unit_2).to receive(:fill_backorder)

          subject.set_count_on_hand(1)
          expect(subject.count_on_hand).to eq(1)
        end
      end
    end
  end

  context "with stock movements" do
    before { Spree::StockMovement.create(stock_item: subject, quantity: 1) }

    it "doesnt raise ReadOnlyRecord error" do
      subject.discard
    end
  end

  context "destroyed" do
    before { subject.discard }

    it "recreates stock item just fine" do
      stock_location.stock_items.create!(variant: subject.variant)
    end

    it "doesnt allow recreating more than one stock item at once" do
      stock_location.stock_items.create!(variant: subject.variant)

      expect {
        stock_location.stock_items.create!(variant: subject.variant)
      }.to raise_error ActiveRecord::RecordInvalid
    end
  end

  describe "#after_save" do
    before do
      subject.variant.update_column(:updated_at, 1.day.ago)
    end

    context "inventory_cache_threshold is not set (default)" do
      context "in_stock? changes" do
        it "touches its variant" do
          expect do
            subject.set_count_on_hand(0)
          end.to change { subject.variant.updated_at }
        end
      end

      context "in_stock? does not change" do
        it "touches its variant" do
          expect do
            subject.set_count_on_hand(-1)
          end.to change { subject.variant.updated_at }
        end
      end
    end

    context "inventory_cache_threshold is set" do
      before do
        stub_spree_preferences(inventory_cache_threshold: inventory_cache_threshold)
      end

      let(:inventory_cache_threshold) { 5 }

      before do
        subject.set_count_on_hand(existing_count_on_hand)
        subject.variant.update_column(:updated_at, 1.day.ago)
      end

      context "beginning above threshold" do
        let(:existing_count_on_hand) { 10 }

        it "count on hand falls below threshold" do
          expect do
            subject.set_count_on_hand(3)
          end.to change { subject.variant.updated_at }
        end

        it "count on hand stays above threshold" do
          expect do
            subject.set_count_on_hand(8)
          end.not_to change { subject.variant.updated_at }
        end
      end

      context "beginning below threshold" do
        let(:existing_count_on_hand) { 2 }

        it "count on hand rises above threshold" do
          expect do
            subject.set_count_on_hand(7)
          end.to change { subject.variant.updated_at }
        end

        it "count on hand stays below threshold" do
          expect do
            subject.set_count_on_hand(3)
          end.to change { subject.variant.updated_at }
        end
      end
    end

    context "when deprecated binary_inventory_cache is used" do
      before do
        stub_spree_preferences(binary_inventory_cache: binary_inventory_cache)
        allow(Spree::Deprecation).to receive(:warn)
        subject.set_count_on_hand(9)
      end

      context "binary_inventory_cache is set to true" do
        let(:binary_inventory_cache) { true }

        it "logs a deprecation warning" do
          expect(Spree::Deprecation).to have_received(:warn)
        end
      end

      context "binary_inventory_cache is set to false" do
        let(:binary_inventory_cache) { false }

        it "inventory_cache_threshold remains nil" do
          expect(Spree::Config.inventory_cache_threshold).to be_nil
        end

        it "does not log a deprecation warning" do
          expect(Spree::Deprecation).not_to have_received(:warn)
        end
      end
    end
  end

  describe "#after_touch" do
    before { subject.variant.update_column(:updated_at, 1.day.ago) }

    it "touches its variant" do
      expect do
        subject.touch
      end.to change { subject.variant.updated_at }
    end
  end

  # Regression test for https://github.com/spree/spree/issues/4651
  context "variant" do
    it "can be found even if the variant is soft-deleted" do
      subject.variant.discard
      expect(subject.reload.variant).not_to be_nil
    end
  end

  describe 'validations' do
    before do
      subject.backorderable = backorderable
      subject.send(:count_on_hand=, count_on_hand)
    end

    describe 'count_on_hand' do
      shared_examples_for 'valid count_on_hand' do
        it 'has :no errors_on' do
          expect(subject).to be_valid
          expect(subject.errors[:count_on_hand].size).to eq(0)
        end
      end

      shared_examples_for 'invalid count_on_hand' do
        it 'has the correct error on count_on_hand' do
          expect(subject).not_to be_valid
          expect(subject.errors[:count_on_hand].size).to eq(1)
          expect(subject.errors[:count_on_hand]).to include('must be greater than or equal to 0')
        end
      end

      context 'when backorderable' do
        let(:backorderable) { true }

        context 'when count_on_hand is positive' do
          let(:count_on_hand) { 3 }
          it_should_behave_like "valid count_on_hand"
        end

        context 'when count_on_hand is negative' do
          let(:count_on_hand) { -3 }

          it_should_behave_like "valid count_on_hand"

          it "can't be changed to not backorderable" do
            expect(subject).to be_valid
            subject.backorderable = false
            expect(subject).not_to be_valid
          end
        end
      end

      context 'when not backorderable' do
        let(:backorderable) { false }

        context 'when count_on_hand is positive' do
          let(:count_on_hand) { 3 }
          it_should_behave_like "valid count_on_hand"
        end

        context 'when count_on_hand is negative' do
          let(:count_on_hand) { -3 }

          it_should_behave_like "invalid count_on_hand"
        end
      end
    end
  end
end
