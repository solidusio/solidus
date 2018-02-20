# frozen_string_literal: true

require 'spree/testing_support/sequences'

FactoryBot.define do
  factory :tax_category, class: 'Spree::TaxCategory' do
    name { "TaxCategory - #{rand(999_999)}" }
    tax_code { "TaxCode - #{rand(999_999)}" }
  end
end
