# frozen_string_literal: true

require 'rails_helper'

module Spree
  module Stock
    module LocationSorter
      RSpec.describe Unsorted, type: :model do
        subject { described_class.new(stock_locations) }

        let!(:first_stock_location) { create(:stock_location) }
        let!(:second_stock_location) { create(:stock_location) }
        let(:stock_locations) { Spree::StockLocation.all }

        it 'returns the original stock locations unsorted' do
          expect(subject.sort).to eq(stock_locations)
        end
      end
    end
  end
end
