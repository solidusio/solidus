# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.when_cherry_picked do
  Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

  require 'spree/testing_support/sequences'
end


FactoryBot.define do
  factory :tax_category, class: 'Spree::TaxCategory' do
    name { "TaxCategory - #{rand(999_999)}" }
    tax_code { "TaxCode - #{rand(999_999)}" }
  end
end

