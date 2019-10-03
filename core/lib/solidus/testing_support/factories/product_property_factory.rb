# frozen_string_literal: true

require 'solidus/testing_support/factories/product_factory'
require 'solidus/testing_support/factories/property_factory'

FactoryBot.define do
  factory :product_property, class: 'Solidus::ProductProperty' do
    product
    property
  end
end
