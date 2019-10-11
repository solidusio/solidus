# frozen_string_literal: true

require 'rails_helper'

module Solidus
  module Stock
    module LocationFilter
      RSpec.describe Active, type: :model do
        subject { described_class.new(stock_locations, order) }

        let!(:active_stock_location) { create(:stock_location) }
        let!(:inactive_stock_location) { create(:stock_location, active: false) }
        let(:stock_locations) { Solidus::StockLocation.all }
        let(:order) { instance_double('Solidus::Order') }

        it 'returns only active stock locations' do
          expect(subject.filter).to eq([active_stock_location])
        end
      end
    end
  end
end
