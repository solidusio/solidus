# frozen_string_literal: true

%w(
  stores
  store_credit
  countries
  return_reasons
  states
  stock_locations
  zones
  refund_reasons
  roles
  shipping_categories
).each do |seed|
  puts "Loading seed file: #{seed}"
  require_relative "default/spree/#{seed}"
end
