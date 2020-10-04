# frozen_string_literal: true

require 'rails_helper'

module Spree
  module Stock
    module Splitter
      RSpec.describe Weight, type: :model do
        let(:stock_location) { mock_model(Spree::StockLocation) }
        let(:variant) { build(:base_variant, weight: 100) }

        subject { Weight.new(stock_location) }

        it 'splits and keeps splitting until all packages are underweight' do
          package = Package.new(stock_location)
          4.times { package.add build(:inventory_unit, variant: variant) }
          packages = subject.split([package])
          expect(packages.size).to eq 4
        end

        it 'handles packages that can not be reduced' do
          package = Package.new(stock_location)
          allow(variant).to receive_messages(weight: 200)
          2.times { package.add build(:inventory_unit, variant: variant) }
          packages = subject.split([package])
          expect(packages.size).to eq 2
        end
      end
    end
  end
end
