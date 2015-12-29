ENV['NO_FACTORIES'] = "NO FACTORIES"

require 'spec_helper'
require 'spree/testing_support/factories/stock_location_factory'

RSpec.describe 'stock location factory' do
  let(:factory_class) { Spree::StockLocation }

  describe 'plain stock location' do
    let(:factory) { :stock_location }

    it_behaves_like 'a working factory'
  end

  describe 'stock location without variant propagation' do
    let(:factory) { :stock_location_without_variant_propagation }

    it_behaves_like 'a working factory'
  end

  describe 'stock location with items' do
    let(:factory) { :stock_location_with_items }

    it_behaves_like 'a working factory'
  end
end
