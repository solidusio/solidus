# frozen_string_literal: true

attrs = [:id, :month, :year, :cc_type, :last_digits, :name]
if current_user_roles.include?("admin")
  attrs += [:gateway_customer_profile_id, :gateway_payment_profile_id]
end

json.call(payment_source, *attrs)
