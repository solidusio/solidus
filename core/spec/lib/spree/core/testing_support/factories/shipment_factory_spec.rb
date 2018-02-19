# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/factories/shipment_factory'

RSpec.describe 'shipment factory' do
  let(:factory_class) { Spree::Shipment }

  describe 'plain shipment' do
    let(:factory) { :shipment }

    it_behaves_like 'a working factory'
  end
end
