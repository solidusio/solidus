# frozen_string_literal: true

require 'rails_helper'

module Spree
  module Stock
    module LocationSorter
      RSpec.describe Unsorted, type: :model do
        subject { described_class.new(stock_locations) }

        let(:stock_locations) { instance_double('Spree::StockLocation::ActiveRecord_Relation') }

        it 'returns the original stock locations unsorted' do
          expect(subject.sort).to eq(stock_locations)
        end
      end
    end
  end
end
