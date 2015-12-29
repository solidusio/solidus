require 'spec_helper'
require 'spree/testing_support/factories/stock_transfer_factory'

RSpec.describe 'stock transfer factory' do
  let(:factory_class) { Spree::StockTransfer }

  describe 'plain stock transfer' do
    let(:factory) { :stock_transfer }

    it_behaves_like 'a working factory'
  end
end
