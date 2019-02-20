# frozen_string_literal: true

require 'rails_helper'

module Spree
  module Stock
    module LocationFilter
      RSpec.describe Active, type: :model do
        subject { described_class.new(stock_locations, order) }

        let(:stock_locations) { instance_double('Spree::StockLocation::ActiveRecord_Relation') }
        let(:order) { instance_double('Spree::Order') }

        it 'returns only active stock locations' do
          active_stock_locations = instance_double('Spree::StockLocation::ActiveRecord_Relation')
          expect(stock_locations).to receive(:active) { active_stock_locations }

          expect(subject.filter).to eq(active_stock_locations)
        end
      end
    end
  end
end
