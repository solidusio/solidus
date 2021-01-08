# frozen_string_literal: true

require 'spree/testing_support'
Spree::TestingSupport.deprecate_cherry_picking_factory_bot_files

FactoryBot.define do
  factory :tax_category, class: 'Spree::TaxCategory' do
    name { "TaxCategory - #{rand(999_999)}" }
    tax_code { "TaxCode - #{rand(999_999)}" }
  end
end
