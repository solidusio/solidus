# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/factories/stock_item_factory'

RSpec.describe 'stock item factory' do
  let(:factory_class) { Spree::StockItem }

  describe 'plain stock item' do
    let(:factory) { :stock_item }

    it_behaves_like 'a working factory'
  end
end
