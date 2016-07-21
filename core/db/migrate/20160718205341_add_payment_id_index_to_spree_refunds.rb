class AddPaymentIdIndexToSpreeRefunds < ActiveRecord::Migration
  def change
    add_index(:spree_refunds, :payment_id)
  end
end
