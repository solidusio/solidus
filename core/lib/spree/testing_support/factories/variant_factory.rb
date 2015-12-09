FactoryGirl.define do
  sequence(:random_float) { BigDecimal.new("#{rand(200)}.#{rand(99)}") }

  factory :base_variant, class: Spree::Variant do
    price 19.99
    cost_price 17.00
    sku    { generate(:sku) }
    is_master 0
    track_inventory true

    product { |p| p.association(:base_product) }
    option_values { [create(:option_value)] }

    # ensure stock item will be created for this variant
    before(:create) { create(:stock_location) if Spree::StockLocation.count == 0 }

    factory :variant do
      # on_hand 5
      product { |p| p.association(:product) }

      factory :variant_in_stock do

        transient do
          count_on_hand 1
        end

        after(:create) do |variant, evaluator|
          variant.stock_locations.first.stock_items.where(:variant_id => variant.id).first.adjust_count_on_hand(evaluator.count_on_hand)
        end
      end
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
