# frozen_string_literal: true

json.users(@users) do |user|
  json.partial!("spree/api/users/user", user: user)
end
json.partial! 'spree/api/shared/pagination', pagination: @users
