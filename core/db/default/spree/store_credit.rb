# frozen_string_literal: true


Spree::PaymentMethod.create_with(
  name: "Store Credit",
  description: "Store credit",
  active: true,
  available_to_admin: false,
  available_to_users: false
).find_or_create_by!(
  type: "Spree::PaymentMethod::StoreCredit"
)

Spree::StoreCreditType.create_with(priority: 1).find_or_create_by!(name: Spree::StoreCreditType::EXPIRING)
Spree::StoreCreditType.create_with(priority: 2).find_or_create_by!(name: Spree::StoreCreditType::NON_EXPIRING)

Spree::ReimbursementType.create_with(name: "Store Credit").find_or_create_by!(type: 'Spree::ReimbursementType::StoreCredit')
Spree::ReimbursementType.create_with(name: "Original").find_or_create_by!(type: 'Spree::ReimbursementType::OriginalPayment')

Spree::StoreCreditCategory.find_or_create_by!(name: Spree::StoreCreditCategory::GIFT_CARD)
Spree::StoreCreditCategory.find_or_create_by!(name: Spree::StoreCreditCategory::REIMBURSEMENT)

Spree::StoreCreditReason.find_or_create_by!(name: 'Credit Given In Error')
