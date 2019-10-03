# frozen_string_literal: true

require 'solidus/testing_support/factories/variant_factory'

FactoryBot.define do
  factory :price, class: 'Solidus::Price' do
    variant
    amount { 19.99 }
    currency { 'USD' }
  end
end
