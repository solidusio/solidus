# frozen_string_literal: true

require 'rails_helper'

module Spree
  module Stock
    module LocationFilter
      RSpec.describe Active, type: :model do
        subject { described_class.new(stock_locations, order) }

        let!(:active_stock_location) { create(:stock_location) }
        let!(:inactive_stock_location) { create(:stock_location, active: false) }
        let(:stock_locations) { Spree::StockLocation.all }
        let(:order) { instance_double('Spree::Order') }

        it 'returns only active stock locations' do
          expect(subject.filter).to eq([active_stock_location])
        end
      end
    end
  end
end
