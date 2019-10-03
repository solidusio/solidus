# frozen_string_literal: true

require 'solidus/testing_support/factories/product_factory'
require 'solidus/testing_support/factories/option_type_factory'

FactoryBot.define do
  factory :product_option_type, class: 'Solidus::ProductOptionType' do
    product
    option_type
  end
end
