require 'spree/testing_support/factories/address_factory'
require 'spree/testing_support/factories/shipment_factory'
require 'spree/testing_support/factories/store_factory'
require 'spree/testing_support/factories/user_factory'
require 'spree/testing_support/factories/line_item_factory'
require 'spree/testing_support/factories/payment_factory'

FactoryGirl.define do
  factory :order, class: Spree::Order do
    association :user, strategy: :build
    association :bill_address, strategy: :build
    association :ship_address, strategy: :build
    completed_at nil
    email { user.nil? ? "user@example.com" : user.email  }
    association :store, strategy: :build

    transient do
      line_items_count 0
      line_items_price BigDecimal.new(10)
      line_items_attributes { [{price: line_items_price, variant: build(:variant), quantity: 1}] * line_items_count }
      shipment_cost 100
      shipping_method nil
      stock_location { create(:stock_location) }
    end

    after(:build) do |order, evaluator|
      evaluator.line_items_attributes.each do |line_item_attributes|
        order.line_items << build(:line_item, {order: order}.merge(line_item_attributes))
      end
      if evaluator.shipping_method
        order.shipments << build(
          :shipment,
          order: order,
          inventory_units: order.line_items.flat_map do |line_item|
                            inventory_units = []
                            line_item.quantity.times do
                              inventory_units << build(
                                :inventory_unit,
                                order: order,
                                line_item: line_item,
                                variant: line_item.variant
                              )
                            end
                            inventory_units
                          end,
          address: order.ship_address,
          stock_location: build(:stock_location)
        )
        order.shipments.each do |shipment|
          shipment.shipping_rates.build(
            cost: evaluator.shipment_cost,
            shipping_method: evaluator.shipping_method
          )
        end
      end
    end

    after(:create) do |order, evaluator|
      order.update!
    end

    factory :order_with_totals do
      transient do
        line_items_count 1
      end
    end

    factory :order_with_line_items do
      transient do
        line_items_count 1
        shipping_method { create(:shipping_method) }
      end

      factory :completed_order_with_totals do
        state 'complete'

        after(:create) do |order|
          order.refresh_shipment_rates
          order.update_column(:completed_at, Time.current)
        end

        factory :completed_order_with_pending_payment do
          after(:create) do |order|
            create(:payment, amount: order.total, order: order, state: 'pending')
          end
        end

        factory :order_ready_to_ship do
          payment_state 'paid'
          shipment_state 'ready'

          transient do
            payment_type :credit_card_payment
          end

          after(:create) do |order, evaluator|
            create(evaluator.payment_type, amount: order.total, order: order, state: 'completed')
            order.shipments.each do |shipment|
              shipment.inventory_units.update_all state: 'on_hand'
              shipment.update_column('state', 'ready')
            end
            order.reload
          end

          factory :shipped_order do
            transient do
              with_cartons true
            end
            after(:create) do |order, evaluator|
              order.shipments.each do |shipment|
                shipment.inventory_units.update_all state: 'shipped'
                shipment.update_columns(state: 'shipped', shipped_at: Time.current)
                next unless evaluator.with_cartons
                Spree::Carton.create!(
                  stock_location: shipment.stock_location,
                  address: shipment.address,
                  shipping_method: shipment.shipping_method,
                  inventory_units: shipment.inventory_units,
                  shipped_at: Time.current
                )
              end
              order.reload
            end
          end
        end
      end
    end
  end

  factory :completed_order_with_promotion, parent: :completed_order_with_totals, class: "Spree::Order" do
    transient do
      promotion nil
      promotion_code nil
    end

    after(:create) do |order, evaluator|
      promotion = evaluator.promotion || create(:promotion, code: "test")
      promotion_code = evaluator.promotion_code || promotion.codes.first

      promotion.actions.each do |action|
        action.perform({ order: order, promotion: promotion, promotion_code: promotion_code })
      end
    end
  end
end
