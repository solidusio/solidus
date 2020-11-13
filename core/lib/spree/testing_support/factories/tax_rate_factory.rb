# frozen_string_literal: true

require 'spree/testing_support'
Spree::TestingSupport.deprecate_cherry_picking_factory_bot_files

FactoryBot.define do
  factory :tax_rate, class: 'Spree::TaxRate' do
    zone
    amount { 0.1 }
    association(:calculator, factory: :default_tax_calculator)
    tax_categories { [build(:tax_category)] }
  end
end
