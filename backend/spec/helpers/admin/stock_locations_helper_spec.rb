# frozen_string_literal: true

require 'spec_helper'

describe Spree::Admin::StockLocationsHelper, type: :helper do
  describe "#admin_stock_location_display_name" do
    subject { helper.admin_stock_location_display_name(stock_location) }

    context "without admin_name" do
      let(:stock_location) { create(:stock_location_with_items) }

      it { is_expected.to eq "NY Warehouse" }
    end

    context "with admin_name" do
      let(:stock_location) { create(:stock_location_with_items, admin_name: "solidus") }

      it { is_expected.to eq "solidus / NY Warehouse" }
    end
  end
end
