# frozen_string_literal: true

require 'rails_helper'

module Spree
  module Stock
    module LocationSorter
      RSpec.describe DefaultFirst, type: :model do
        subject { described_class.new(stock_locations) }

        let(:stock_locations) { OpenStruct.new(order_default: sorted_stock_locations) }
        let(:sorted_stock_locations) { instance_double('Spree::StockLocation::ActiveRecord_Relation') }

        it 'returns the default stock location first' do
          expect(subject.sort).to eq(sorted_stock_locations)
        end
      end
    end
  end
end
