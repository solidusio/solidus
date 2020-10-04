# frozen_string_literal: true

namespace :order_capturing do
  desc "Looks for orders with inventory that is fully shipped/short-shipped, and captures money for it"
  task capture_payments: :environment do
    Spree::Deprecation.warn("rake order_capturing:capture_payments has been deprecated and will be removed with Solidus 3.0.")

    failures = []
    orders = Spree::Order.complete.where(payment_state: 'balance_due').where('completed_at > ?', Spree::Config[:order_capturing_time_window].days.ago)

    orders.find_each do |order|
      if order.inventory_units.all? { |iu| iu.canceled? || iu.shipped? }
        if Spree::OrderCapturing.failure_handler
          begin
            Spree::OrderCapturing.new(order).capture_payments
          rescue StandardError => e
            failures << { message: "Order #{order.number} unable to capture. #{e.class}: #{e.message}" }
          end
        else
          Spree::OrderCapturing.new(order).capture_payments
        end
      end
    end

    Spree::OrderCapturing.failure_handler.call(failures) if failures.any?
  end
end
