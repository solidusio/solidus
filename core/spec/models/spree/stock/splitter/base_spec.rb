# frozen_string_literal: true

require 'rails_helper'

module Spree
  module Stock
    module Splitter
      RSpec.describe Base, type: :model do
        let(:stock_location) { mock_model(Spree::StockLocation) }

        it 'continues to splitter chain' do
          splitter1 = Base.new(stock_location)
          splitter2 = Base.new(stock_location, splitter1)
          packages = []

          expect(splitter1).to receive(:split).with(packages)
          splitter2.split(packages)
        end
      end
    end
  end
end
