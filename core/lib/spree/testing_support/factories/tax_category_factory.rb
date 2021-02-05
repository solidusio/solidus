# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

FactoryBot.define do
  factory :tax_category, class: 'Spree::TaxCategory' do
    name { "TaxCategory - #{rand(999_999)}" }
    tax_code { "TaxCode - #{rand(999_999)}" }
  end
end
