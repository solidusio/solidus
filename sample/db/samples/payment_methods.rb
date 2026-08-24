# frozen_string_literal: true

Spree::PaymentMethod::BogusCreditCard.find_or_create_by!(name: "Credit Card") do |payment_method|
  payment_method.description = "Bogus payment gateway"
  payment_method.active = true
end

Spree::PaymentMethod::Check.find_or_create_by!(name: "Check") do |payment_method|
  payment_method.description = "Pay by check."
  payment_method.active = true
end
