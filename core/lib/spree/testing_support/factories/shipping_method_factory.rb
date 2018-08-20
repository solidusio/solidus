# frozen_string_literal: true

require 'spree/testing_support/factories/calculator_factory'
require 'spree/testing_support/factories/shipping_category_factory'
require 'spree/testing_support/factories/zone_factory'

FactoryBot.define do
  factory(
    :shipping_method,
    aliases: [
      :base_shipping_method
    ],
    class: 'Spree::ShippingMethod'
  ) do
    zones do
      [Spree::Zone.find_by(name: 'GlobalZone') || FactoryBot.create(:global_zone)]
    end

    name { 'UPS Ground' }
    code { 'UPS_GROUND' }
    carrier { 'UPS' }
    service_level { '1DAYGROUND' }

    calculator { |s| s.association(:shipping_calculator, strategy: :build, preferred_amount: s.cost, preferred_currency: s.currency) }

    transient do
      cost { 10.0 }
      currency { Spree::Config[:currency] }
    end

    before(:create) do |shipping_method, _evaluator|
      if shipping_method.shipping_categories.empty?
        shipping_method.shipping_categories << (Spree::ShippingCategory.first || create(:shipping_category))
      end
    end

    factory :free_shipping_method, class: 'Spree::ShippingMethod' do
      cost { nil }
      association(:calculator, factory: :shipping_no_amount_calculator, strategy: :build)
    end
  end
end
