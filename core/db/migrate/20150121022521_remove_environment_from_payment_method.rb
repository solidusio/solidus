class RemoveEnvironmentFromPaymentMethod < ActiveRecord::Migration
  def up
    Solidus::PaymentMethod.where('environment != ?', Rails.env).update_all(active: false)
    remove_column :spree_payment_methods, :environment
  end
end
