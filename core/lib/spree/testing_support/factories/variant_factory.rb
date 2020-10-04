# frozen_string_literal: true

require 'spree/testing_support/sequences'
require 'spree/testing_support/factories/option_value_factory'
require 'spree/testing_support/factories/option_type_factory'
require 'spree/testing_support/factories/product_factory'

FactoryBot.define do
  sequence(:random_float) { BigDecimal("#{rand(200)}.#{rand(99)}") }

  factory :base_variant, class: 'Spree::Variant' do
    price { 19.99 }
    cost_price { 17.00 }
    sku { generate(:sku) }
    is_master { 0 }
    track_inventory { true }

    product { |p| p.association(:base_product) }

    # ensure stock item will be created for this variant
    before(:create) { create(:stock_location) if Spree::StockLocation.count == 0 }

    factory :variant do
      # on_hand 5
      product { |p| p.association(:product) }
      option_values { [create(:option_value)] }
    end

    factory :master_variant do
      is_master { 1 }
      before(:create){ |variant| variant.product.master = variant }
      product { build(:base_product) }
    end

    factory :on_demand_variant do
      track_inventory { false }

      factory :on_demand_master_variant do
        is_master { 1 }
      end
    end
  end
end
