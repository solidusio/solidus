# frozen_string_literal: true

FactoryBot.define do
  factory :order, class: "Spree::Order" do
    user
    bill_address
    ship_address
    completed_at { nil }
    email { user.try(:email) }
    association :store, strategy: :create

    transient do
      line_items_price { BigDecimal(10) }
    end

    # TODO: Improve the name of order_with_totals factory.
    factory :order_with_totals do
      after(:build) do |order, evaluator|
        order.line_items << build(
          :line_item,
          price: evaluator.line_items_price
        )
      end

      after(:create) do |order|
        order.recalculate
      end
    end

    factory :order_with_line_items do
      bill_address
      ship_address

      transient do
        line_items_count { 1 }
        line_items_attributes { [{}] * line_items_count }
        shipment_cost { 100 }
        shipping_method { nil }
        stock_location { create(:stock_location) }
      end

      after(:build) do |order, evaluator|
        evaluator.stock_location # must evaluate before creating line items

        evaluator.line_items_attributes.each do |attributes|
          attributes = {order:, price: evaluator.line_items_price}.merge(attributes).tap do |attrs|
            tax_category = attributes.delete(:tax_category)
            if attrs[:variant] && tax_category
              attrs[:variant].update(tax_category:)
            elsif tax_category
              attrs[:variant] = create(:variant, tax_category:)
            end
          end

          create(:line_item, attributes)
        end
        order.line_items.reload

        create(:shipment, order:, cost: evaluator.shipment_cost, shipping_method: evaluator.shipping_method, stock_location: evaluator.stock_location)
        order.shipments.reload

        order.recalculate
      end

      factory :order_ready_to_complete do
        state { "confirm" }
        payment_state { "checkout" }

        transient do
          payment_type { :credit_card_payment }
        end

        after(:create) do |order, evaluator|
          create(evaluator.payment_type, {
            amount: order.total,
            order:,
            state: order.payment_state
          })

          order.payments.reload
        end
      end

      factory :completed_order_with_totals do
        transient do
          completed_at { Time.current }
        end
        state { "complete" }

        after(:create) do |order, evaluator|
          order.shipments.each do |shipment|
            shipment.inventory_units.update_all state: "on_hand", pending: false
          end
          order.update_column(:completed_at, evaluator.completed_at)
        end

        factory :completed_order_with_pending_payment do
          after(:create) do |order|
            create(:payment, amount: order.total, order:, state: "pending")
          end
        end

        factory :order_ready_to_ship do
          payment_state { "paid" }
          shipment_state { "ready" }

          transient do
            payment_type { :credit_card_payment }
          end

          after(:create) do |order, evaluator|
            create(evaluator.payment_type, amount: order.total, order:, state: "completed")
            order.shipments.each do |shipment|
              shipment.update_column("state", "ready")
            end
            order.reload
          end

          factory :shipped_order do
            transient do
              with_cartons { true }
            end
            after(:create) do |order, evaluator|
              order.shipments.each do |shipment|
                shipment.inventory_units.update_all state: "shipped"
                shipment.update_columns(state: "shipped", shipped_at: Time.current)
                next unless evaluator.with_cartons
                Spree::Carton.create!(
                  stock_location: shipment.stock_location,
                  address: order.ship_address,
                  shipping_method: shipment.shipping_method,
                  inventory_units: shipment.inventory_units,
                  shipped_at: Time.current
                )
              end
              # We need to update the shipment_state after all callbacks have run
              order.update_columns(shipment_state: "shipped")
              order.reload
            end
          end
        end
      end
    end
  end
end
