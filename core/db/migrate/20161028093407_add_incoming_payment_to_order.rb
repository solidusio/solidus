class AddIncomingPaymentToOrder < ActiveRecord::Migration[5.0]
  def change
    add_column :spree_orders, :incoming_payment, :decimal, precision: 10, scale: 2, default: 0.0
    remove_column :spree_orders, :payment_total, :decimal, precision: 10, scale: 2, default: 0.0

    reversible do |direction|
      direction.up do
        Spree::Order.all.each {|o| o.update_incoming_payment }
      end

      direction.down do
        Spree::Order.all.each do |o|
          o.payment_total = o.payments.completed.includes(:refunds).map { |payment| payment.amount - payment.refunds.sum(:amount) }.sum
        end
      end
    end
  end
end
