# frozen_string_literal: true

require 'rails_helper'

module Spree
  module Stock
    module LocationSorter
      RSpec.describe DefaultFirst, type: :model do
        subject { described_class.new(stock_locations) }

        let!(:first) { create(:stock_location, default: false, position: 2) }
        let!(:second) { create(:stock_location, default: true, position: 3) }
        let!(:third) { create(:stock_location, default: false, position: 1) }
        let!(:fourth) { create(:stock_location, default: false, position: 4) }
        let(:stock_locations) { Spree::StockLocation.all }
        let(:sorted_stock_locations) { [second, third, first, fourth] }

        it 'returns the default stock location first and the remaining locations by position' do
          expect(subject.sort).to eq(sorted_stock_locations)
        end
      end
    end
  end
end

