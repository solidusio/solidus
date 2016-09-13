class AddPaymentIdIndexToSpreeRefunds < ActiveRecord::Migration[4.2]
  def change
    add_index(:spree_refunds, :payment_id)
  end
end
