# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/factories/inventory_unit_factory'

RSpec.describe 'inventory unit factory' do
  let(:factory_class) { Spree::InventoryUnit }

  describe 'plain inventory unit' do
    let(:factory) { :inventory_unit }

    it_behaves_like 'a working factory'
  end
end
