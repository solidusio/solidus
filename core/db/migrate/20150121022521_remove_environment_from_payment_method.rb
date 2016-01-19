class RemoveEnvironmentFromPaymentMethod < ActiveRecord::Migration
  def up
    Spree::PaymentMethod.unscoped.where('environment != ?', Rails.env).update_all(active: false)
    remove_column :spree_payment_methods, :environment
  end
end
