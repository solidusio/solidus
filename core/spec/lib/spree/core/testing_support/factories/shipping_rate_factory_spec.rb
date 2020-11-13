# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'shipping rate factory' do
  let(:factory_class) { Spree::ShippingRate }

  describe 'plain shipping rate' do
    let(:factory) { :shipping_rate }

    it_behaves_like 'a working factory'
  end
end
