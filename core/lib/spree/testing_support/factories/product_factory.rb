# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.when_cherry_picked do
  Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

  require 'spree/testing_support/sequences'
  require 'spree/testing_support/factories/shipping_category_factory'
  require 'spree/testing_support/factories/stock_location_factory'
  require 'spree/testing_support/factories/tax_category_factory'
  require 'spree/testing_support/factories/product_option_type_factory'
end

FactoryBot.define do
  factory :base_product, class: 'Spree::Product' do
    sequence(:name) { |n| "Product ##{n} - #{Kernel.rand(9999)}" }
    description { "As seen on TV!" }
    price { 19.99 }
    cost_price { 17.00 }
    sku { generate(:sku) }
    available_on { 1.year.ago }
    deleted_at { nil }
    shipping_category do |r|
      Spree::ShippingCategory.first ||
        r.association(:shipping_category, strategy: :create)
    end

    # ensure stock item will be created for this products master
    before(:create) { create(:stock_location) if Spree::StockLocation.count == 0 }

    factory :custom_product do
      name { 'Custom Product' }
      price { 17.99 }

      tax_category { |r| Spree::TaxCategory.first || r.association(:tax_category) }
    end

    factory :product do
      tax_category { |r| Spree::TaxCategory.first || r.association(:tax_category) }

      factory :product_in_stock do
        after :create do |product|
          product.master.stock_items.first.adjust_count_on_hand(10)
        end

        factory :product_not_backorderable do
          after :create do |product|
            product.master.stock_items.first.update_column(:backorderable, false)
          end
        end
      end

      factory :product_with_option_types do
        after(:create) { |product| create(:product_option_type, product: product) }
      end
    end
  end
end

