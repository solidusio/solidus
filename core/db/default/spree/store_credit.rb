Spree::StoreCreditCategory.find_or_create_by!(name: Spree.t("store_credit_category.default"))

Spree::PaymentMethod.create_with(
  name: Spree.t("store_credit.store_credit"),
  description: Spree.t("store_credit.store_credit"),
  active: true,
  display_on: 'none',
).find_or_create_by!(
  type: "Spree::PaymentMethod::StoreCredit",
  environment: Rails.env,
)

Spree::StoreCreditType.create_with(priority: 1).find_or_create_by!(name: Spree.t("store_credit.expiring"))
Spree::StoreCreditType.create_with(priority: 2).find_or_create_by!(name: Spree.t("store_credit.non_expiring"))

Spree::ReimbursementType.create_with(name: Spree.t("store_credit.store_credit")).find_or_create_by!(type: 'Spree::ReimbursementType::StoreCredit')
