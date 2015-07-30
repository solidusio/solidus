class CreateSpreeStoreCreditPaymentMethod < ActiveRecord::Migration
  class PaymentMethod < ActiveRecord::Base
    self.table_name = 'spree_payment_methods'
    self.inheritance_column = :_type_disabled
  end

  def up
    # Check if there is an environment column for users
    # that are migrating from Spree 3.0.
    if PaymentMethod.column_names.include? 'environment'
      PaymentMethod.create_with(
        name: Spree.t("store_credit.store_credit"),
        description: Spree.t("store_credit.store_credit"),
        active: true,
        display_on: 'none',
      ).find_or_create_by!(
        type: "Spree::PaymentMethod::StoreCredit",
        environment: Rails.env,
      )
    else
      PaymentMethod.create_with(
        name: Spree.t("store_credit.store_credit"),
        description: Spree.t("store_credit.store_credit"),
        active: true,
        display_on: 'none',
      ).find_or_create_by!(
        type: "Spree::PaymentMethod::StoreCredit"
      )
    end
  end
end
