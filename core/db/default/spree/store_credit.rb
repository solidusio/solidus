# frozen_string_literal: true

Solidus::StoreCreditCategory.find_or_create_by!(name: I18n.t('spree.store_credit_category.default'))

Solidus::PaymentMethod.create_with(
  name: "Store Credit",
  description: "Store credit",
  active: true,
  available_to_admin: false,
  available_to_users: false
).find_or_create_by!(
  type: "Solidus::PaymentMethod::StoreCredit"
)

Solidus::StoreCreditType.create_with(priority: 1).find_or_create_by!(name: Solidus::StoreCreditType::EXPIRING)
Solidus::StoreCreditType.create_with(priority: 2).find_or_create_by!(name: Solidus::StoreCreditType::NON_EXPIRING)

Solidus::ReimbursementType.create_with(name: "Store Credit").find_or_create_by!(type: 'Solidus::ReimbursementType::StoreCredit')
Solidus::ReimbursementType.create_with(name: "Original").find_or_create_by!(type: 'Solidus::ReimbursementType::OriginalPayment')

Solidus::StoreCreditCategory.find_or_create_by!(name: 'Gift Card')

Solidus::StoreCreditReason.find_or_create_by!(name: 'Credit Given In Error')
