# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Stock::ShippingRateSorter do
  describe '#sort' do
    it 'sorts by increasing cost' do
      cheapest_shipping_rate = Spree::ShippingRate.new(cost: 1.00)
      middle_shipping_rate = Spree::ShippingRate.new(cost: 5.00)
      expensive_shipping_rate = Spree::ShippingRate.new(cost: 42.00)
      shipping_rates = [expensive_shipping_rate, middle_shipping_rate, cheapest_shipping_rate]

      sorter = Spree::Stock::ShippingRateSorter.new(shipping_rates)

      expect(sorter.sort).to eq([cheapest_shipping_rate, middle_shipping_rate, expensive_shipping_rate])
    end
  end
end
