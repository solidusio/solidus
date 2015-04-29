FactoryGirl.define do
  factory :stock_transfer, class: Spree::StockTransfer do
    source_location      Spree::StockLocation.new(name: "Source Location", code: "SRC")
    destination_location Spree::StockLocation.new(name: "Destination Location", code: "DEST")

    factory :stock_transfer_with_items do
      after(:create) do |stock_transfer, evaluator|
         variant_1 = create(:variant)
         variant_2 = create(:variant)

         variant_1.stock_items.find_by(stock_location: stock_transfer.source_location).set_count_on_hand(10)
         variant_2.stock_items.find_by(stock_location: stock_transfer.source_location).set_count_on_hand(10)

         stock_transfer.transfer_items.create(variant: variant_1, expected_quantity: 5)
         stock_transfer.transfer_items.create(variant: variant_2, expected_quantity: 5)
      end

      factory :receivable_stock_transfer_with_items do
        finalized_at   Time.now
        shipped_at     Time.now
      end
    end
  end
end
