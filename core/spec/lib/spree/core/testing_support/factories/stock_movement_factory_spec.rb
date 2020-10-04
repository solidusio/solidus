# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/factories/stock_movement_factory'

RSpec.describe 'stock movement factory' do
  let(:factory_class) { Spree::StockMovement }

  describe 'plain stock movement' do
    let(:factory) { :stock_movement }

    it_behaves_like 'a working factory'
  end
end
