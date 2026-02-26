# frozen_string_literal: true

FactoryBot.define do
  factory :stock_item, class: "Spree::StockItem" do
    backorderable { true }
    association :stock_location, factory: :stock_location_without_variant_propagation
    variant

    transient do
      on_hand { 10 }
    end

    after(:create) { |object, evaluator| object.adjust_count_on_hand(evaluator.on_hand) }
  end
end
