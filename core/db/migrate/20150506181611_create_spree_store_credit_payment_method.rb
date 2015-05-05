class CreateSpreeStoreCreditPaymentMethod < ActiveRecord::Migration
  def up
    Spree::PaymentMethod.create_with(
      name: Spree.t("store_credit.store_credit"),
      description: Spree.t("store_credit.store_credit"),
      active: true,
      display_on: 'none',
    ).find_or_create_by!(
      type: "Spree::PaymentMethod::StoreCredit",
      environment: Rails.env,
    )
  end
end
