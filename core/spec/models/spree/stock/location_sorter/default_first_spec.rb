# frozen_string_literal: true

require 'rails_helper'

module Spree
  module Stock
    module LocationSorter
      RSpec.describe DefaultFirst, type: :model do
        subject { described_class.new(stock_locations) }

        let!(:first_stock_location) { create(:stock_location, default: false) }
        let!(:second_stock_location) { create(:stock_location, default: true) }
        let(:stock_locations) { Spree::StockLocation.all }
        let(:sorted_stock_locations) { stock_locations.reverse }

        it 'returns the default stock location first' do
          expect(subject.sort).to eq(sorted_stock_locations)
        end
      end
    end
  end
end
