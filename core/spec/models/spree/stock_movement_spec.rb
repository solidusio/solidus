# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::StockMovement, type: :model do
  let(:stock_location) { create(:stock_location_with_items) }
  let(:stock_item) { stock_location.stock_items.order(:id).first }
  subject { build(:stock_movement, stock_item:) }

  it 'should belong to a stock item' do
    expect(subject).to respond_to(:stock_item)
  end

  it 'should have a variant' do
    expect(subject).to respond_to(:variant)
  end

  it 'is readonly unless new' do
    subject.save
    expect {
      subject.save
    }.to raise_error(ActiveRecord::ReadOnlyRecord)
  end

  it 'does not update count on hand when track inventory levels is false' do
    stub_spree_preferences(track_inventory_levels: false)
    subject.quantity = 1
    subject.save
    stock_item.reload
    expect(stock_item.count_on_hand).to eq(10)
  end

  it 'does not update count on hand when variant inventory tracking is off' do
    stock_item.variant.track_inventory = false
    subject.quantity = 1
    subject.save
    stock_item.reload
    expect(stock_item.count_on_hand).to eq(10)
  end

  context "when quantity is negative" do
    context "after save" do
      it "should decrement the stock item count on hand" do
        subject.quantity = -1
        subject.save
        stock_item.reload
        expect(stock_item.count_on_hand).to eq(9)
      end
    end
  end

  context "when quantity is positive" do
    context "after save" do
      it "should increment the stock item count on hand" do
        subject.quantity = 1
        subject.save
        stock_item.reload
        expect(stock_item.count_on_hand).to eq(11)
      end
    end
  end

  describe "metadata fields" do
    it "responds to public_metadata" do
      expect(subject).to respond_to(:public_metadata)
    end

    it "responds to private_metadata" do
      expect(subject).to respond_to(:private_metadata)
    end

    it "can store data in public_metadata" do
      subject.public_metadata = { "movement_reason" => "restock" }
      expect(subject.public_metadata["movement_reason"]).to eq("restock")
    end

    it "can store data in private_metadata" do
      subject.private_metadata = { "internal_note" => "Inventory verified" }
      expect(subject.private_metadata["internal_note"]).to eq("Inventory verified")
    end
  end
end
