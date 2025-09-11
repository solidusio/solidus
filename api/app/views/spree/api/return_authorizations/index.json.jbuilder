# frozen_string_literal: true

json.return_authorizations(@return_authorizations) do |return_authorization|
  json.call(return_authorization, *return_authorization_attributes)
end
json.partial! "spree/api/shared/pagination", pagination: @return_authorizations
