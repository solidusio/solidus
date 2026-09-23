# frozen_string_literal: true

# create payments based on the totals since they can't be known in YAML (quantities are random)
method = Spree::PaymentMethod.where(name: "Credit Card", active: true).first

# This table was previously called spree_creditcards, and older migrations
# reference it as such. Make it explicit here that this table has been renamed.
Spree::CreditCard.table_name = "spree_credit_cards"

creditcard = Spree::CreditCard.find_or_create_by!(cc_type: "visa", last_digits: "1111", name: "Sean Schofield") do |cc|
  cc.month = 12
  cc.year = 2.years.from_now.year
  cc.gateway_customer_profile_id = "BGS-1234"
end

Spree::Order.all.each_with_index do |order, _index|
  order.recalculate
  payment = order.payments.find_or_create_by!(payment_method: method) do |p|
    p.amount = order.total
    p.source = creditcard.clone
  end
  payment.update_columns(state: "pending", response_code: "12345") if payment.previously_new_record?
end
