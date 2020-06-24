# frozen_string_literal: true

require 'spec_helper'

describe Spree::Admin::StockMovementsHelper, type: :helper do
  describe "#pretty_originator" do
    let!(:stock_location) { create(:stock_location_with_items) }
    let!(:stock_item)     { stock_location.stock_items.first }
    let(:stock_movement)  { create(:stock_movement, stock_item: stock_item, originator: originator) }

    subject { helper.pretty_originator(stock_movement) }

    context "originator has a number" do
      let(:originator) { build(:order) }

      it "returns the originator's number" do
        expect(subject).to eq originator.number
      end
    end

    context "originator has an email" do
      let(:originator) { build(:user, email: "stock_mover@example.com") }

      it "returns the originator's email" do
        expect(subject).to eq "stock_mover@example.com"
      end
    end

    context "the stock movement doesn't have an originator" do
      let(:originator) { nil }

      it "returns an empty string" do
        expect(subject).to eq ""
      end
    end
  end
end
