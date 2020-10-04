# frozen_string_literal: true

require 'spree/testing_support/factories/calculator_factory'
require 'spree/testing_support/factories/tax_category_factory'
require 'spree/testing_support/factories/zone_factory'

FactoryBot.define do
  factory :tax_rate, class: 'Spree::TaxRate' do
    zone
    amount { 0.1 }
    association(:calculator, factory: :default_tax_calculator)
    tax_categories { [build(:tax_category)] }
  end
end
