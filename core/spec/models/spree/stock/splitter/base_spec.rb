# frozen_string_literal: true

require 'rails_helper'

module Spree
  module Stock
    module Splitter
      RSpec.describe Base, type: :model do
        let(:stock_location) { mock_model(Spree::StockLocation) }

        it 'continues to splitter chain' do
          splitter_one = Base.new(stock_location)
          splitter_two = Base.new(stock_location, splitter_one)
          packages = []

          expect(splitter_one).to receive(:split).with(packages)
          splitter_two.split(packages)
        end
      end
    end
  end
end
