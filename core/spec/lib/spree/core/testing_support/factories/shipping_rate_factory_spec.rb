# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/factories/shipping_rate_factory'

RSpec.describe 'shipping rate factory' do
  let(:factory_class) { Spree::ShippingRate }

  describe 'plain shipping rate' do
    let(:factory) { :shipping_rate }

    it_behaves_like 'a working factory'
  end
end
