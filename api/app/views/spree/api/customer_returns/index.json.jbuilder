# frozen_string_literal: true

json.customer_returns(@customer_returns) do |customer_return|
  json.(customer_return, *customer_return_attributes)
end
json.partial! 'spree/api/shared/pagination', pagination: @customer_returns
