class RemoveDisplayOnFromPaymentMethods < ActiveRecord::Migration
  def up
    remove_column :solidus_payment_methods, :display_on
  end
end
