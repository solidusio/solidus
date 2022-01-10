FactoryBot.define do
  factory :stock_transfer, class: Spree::StockTransfer do
    source_location { Spree::StockLocation.create!(name: "Source Location", code: "SRC", admin_name: "Source") }

    factory :stock_transfer_with_items do
      destination_location { Spree::StockLocation.create!(name: "Destination Location", code: "DEST", admin_name: "Destination") }

      after(:create) do |stock_transfer, _evaluator|
        variant_1 = create(:variant)
        variant_2 = create(:variant)

        variant_1.stock_items.find_by(stock_location: stock_transfer.source_location).set_count_on_hand(10)
        variant_2.stock_items.find_by(stock_location: stock_transfer.source_location).set_count_on_hand(10)

        stock_transfer.transfer_items.create(variant: variant_1, expected_quantity: 5)
        stock_transfer.transfer_items.create(variant: variant_2, expected_quantity: 5)

        stock_transfer.created_by = create(:admin_user)
        stock_transfer.save!
      end

      factory :receivable_stock_transfer_with_items do
        finalized_at  { Time.current }
        shipped_at    { Time.current }
      end
    end
  end
end
