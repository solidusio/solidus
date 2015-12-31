namespace :order_capturing do
  desc "Looks for orders with inventory that is fully shipped/short-shipped, and captures money for it"
  task capture_payments: :environment do
    failures = []
    orders = Solidus::Order.complete.where(payment_state: 'balance_due').where('completed_at > ?', Solidus::Config[:order_capturing_time_window].days.ago)

    orders.find_each do |order|
      if order.inventory_units.all? {|iu| iu.canceled? || iu.shipped? }
        if Solidus::OrderCapturing.failure_handler
          begin
            Solidus::OrderCapturing.new(order).capture_payments
          rescue Exception => e
            failures << { message: "Order #{order.number} unable to capture. #{e.class}: #{e.message}" }
          end
        else
          Solidus::OrderCapturing.new(order).capture_payments
        end
      end
    end

    Solidus::OrderCapturing.failure_handler.call(failures) if failures.any?
  end
end
