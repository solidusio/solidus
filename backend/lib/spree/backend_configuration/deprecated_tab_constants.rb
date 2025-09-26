# frozen_string_literal: true

Spree.deprecator.warn(
  "Spree::BackendConfiguration::*_TABS is deprecated. Please use Spree::BackendConfiguration::MenuItem(match_path:) instead."
)

Spree::BackendConfiguration::ORDER_TABS = [
  :orders, :payments, :creditcard_payments,
  :shipments, :credit_cards, :return_authorizations,
  :customer_returns, :adjustments, :customer_details
]
Spree::BackendConfiguration::PRODUCT_TABS = [
  :products, :option_types, :properties,
  :variants, :product_properties, :taxonomies,
  :taxons
]
Spree::BackendConfiguration::PROMOTION_TABS = [
  :promotions, :promotion_categories
]
Spree::BackendConfiguration::STOCK_TABS = [
  :stock_items
]
Spree::BackendConfiguration::USER_TABS = [
  :users, :store_credits
]
Spree::BackendConfiguration::CONFIGURATION_TABS = [
  :stores, :tax_categories,
  :tax_rates, :zones,
  :payment_methods, :shipping_methods,
  :shipping_categories, :stock_locations,
  :refund_reasons, :reimbursement_types,
  :return_reasons, :adjustment_reasons,
  :store_credit_reasons
]
