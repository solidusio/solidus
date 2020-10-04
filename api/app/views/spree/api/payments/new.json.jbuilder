# frozen_string_literal: true

json.attributes([*payment_attributes])
json.payment_methods(@payment_methods) do |payment_method|
  json.(payment_method, *payment_method_attributes)
end
