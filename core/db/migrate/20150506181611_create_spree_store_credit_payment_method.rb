class CreateSpreeStoreCreditPaymentMethod < ActiveRecord::Migration
  class PaymentMethod < Spree::Base
    self.table_name = 'spree_payment_methods'
    self.inheritance_column = :_type_disabled
  end
  def up
    # If migrating from Spree 3.0, the environment column is already gone.
    # We remove it in a later migration if upgrading from spree <= 2.4 to soldius
    if column_exists?(:spree_payment_methods, :environment)
      attributes = { type: "Spree::PaymentMethod::StoreCredit", environment: Rails.env }
    else
      attributes = { type: "Spree::PaymentMethod::StoreCredit" }
    end
    PaymentMethod.create_with(
      name: Spree.t("store_credit.store_credit"),
      description: Spree.t("store_credit.store_credit"),
      active: true,
      display_on: 'none'
    ).find_or_create_by!(attributes)
  end
end
