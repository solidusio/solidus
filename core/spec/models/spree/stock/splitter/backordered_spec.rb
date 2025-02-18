# frozen_string_literal: true

require "rails_helper"

module Spree
  module Stock
    module Splitter
      RSpec.describe Backordered, type: :model do
        let(:variant) { build(:variant) }

        let(:stock_location) { mock_model(Spree::StockLocation) }

        subject { Backordered.new(stock_location) }

        it "splits packages by status" do
          package = Package.new(stock_location)
          4.times { package.add build(:inventory_unit, variant:) }
          5.times { package.add build(:inventory_unit, variant:), :backordered }

          packages = subject.split([package])
          expect(packages.count).to eq 2
          expect(packages.first.quantity).to eq 4
          expect(packages.first.on_hand.count).to eq 4
          expect(packages.first.backordered.count).to eq 0

          expect(packages[1].contents.count).to eq 5
        end
      end
    end
  end
end
