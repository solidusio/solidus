FactoryGirl.define do
  sequence(:random_float) { BigDecimal.new("#{rand(200)}.#{rand(99)}") }

  factory :base_variant, class: Solidus::Variant do
    price 19.99
    cost_price 17.00
    sku    { generate(:sku) }
    is_master 0
    track_inventory true

    product { |p| p.association(:base_product) }
    option_values { [create(:option_value)] }

    # ensure stock item will be created for this variant
    before(:create) { create(:stock_location) if Solidus::StockLocation.count == 0 }

    factory :variant do
      # on_hand 5
      product { |p| p.association(:product) }
    end

    factory :master_variant do
      is_master 1
    end

    factory :on_demand_variant do
      track_inventory false

      factory :on_demand_master_variant do
        is_master 1
      end
    end

  end
end
