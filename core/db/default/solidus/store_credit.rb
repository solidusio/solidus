Solidus::StoreCreditCategory.find_or_create_by!(name: Solidus.t("store_credit_category.default"))

Solidus::PaymentMethod.create_with(
  name: "Store Credit",
  description: "Store credit",
  active: true,
  display_on: 'none',
).find_or_create_by!(
  type: "Solidus::PaymentMethod::StoreCredit",
)

Solidus::StoreCreditType.create_with(priority: 1).find_or_create_by!(name: 'Expiring')
Solidus::StoreCreditType.create_with(priority: 2).find_or_create_by!(name: 'Non-expiring')

Solidus::ReimbursementType.create_with(name: "Store Credit").find_or_create_by!(type: 'Solidus::ReimbursementType::StoreCredit')

Solidus::StoreCreditCategory.find_or_create_by!(name: 'Gift Card')

Solidus::StoreCreditUpdateReason.find_or_create_by!(name: 'Credit Given In Error')
