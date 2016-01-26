Spree::StoreCreditCategory.find_or_create_by!(name: Spree.t("store_credit_category.default"))

Spree::PaymentMethod.create_with(
  name: "Store Credit",
  description: "Store credit",
  active: true,
  display_on: 'none'
).find_or_create_by!(
  type: "Spree::PaymentMethod::StoreCredit"
)

Spree::StoreCreditType.create_with(priority: 1).find_or_create_by!(name: 'Expiring')
Spree::StoreCreditType.create_with(priority: 2).find_or_create_by!(name: 'Non-expiring')

Spree::ReimbursementType.create_with(name: "Store Credit").find_or_create_by!(type: 'Spree::ReimbursementType::StoreCredit')

Spree::StoreCreditCategory.find_or_create_by!(name: 'Gift Card')

Spree::StoreCreditUpdateReason.find_or_create_by!(name: 'Credit Given In Error')
