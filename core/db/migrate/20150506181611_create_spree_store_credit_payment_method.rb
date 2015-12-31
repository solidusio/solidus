class CreateSolidusStoreCreditPaymentMethod < ActiveRecord::Migration
  class PaymentMethod < Solidus::Base
    self.table_name = 'solidus_payment_methods'
    self.inheritance_column = :_type_disabled
  end
  def up
    # If migrating from Solidus 3.0, the environment column is already gone.
    # We remove it in a later migration if upgrading from solidus <= 2.4 to soldius
    if column_exists?(:solidus_payment_methods, :environment)
      attributes = {type: "Solidus::PaymentMethod::StoreCredit", environment: Rails.env}
    else
      attributes = {type: "Solidus::PaymentMethod::StoreCredit"}
    end
    PaymentMethod.create_with(
      name: Solidus.t("store_credit.store_credit"),
      description: Solidus.t("store_credit.store_credit"),
      active: true,
      display_on: 'none',
    ).find_or_create_by!(attributes)
  end
end
