# frozen_string_literal: true

require 'thor'
shell = Thor::Base.shell.new

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
  shell.say_status :seed, seed
  require_relative "default/spree/#{seed}"
end
