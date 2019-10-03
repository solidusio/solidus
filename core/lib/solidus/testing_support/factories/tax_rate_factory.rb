# frozen_string_literal: true

require 'solidus/testing_support/factories/calculator_factory'
require 'solidus/testing_support/factories/tax_category_factory'
require 'solidus/testing_support/factories/zone_factory'

FactoryBot.define do
  factory :tax_rate, class: 'Solidus::TaxRate' do
    zone
    amount { 0.1 }
    association(:calculator, factory: :default_tax_calculator)
    tax_categories { [build(:tax_category)] }
  end
end
