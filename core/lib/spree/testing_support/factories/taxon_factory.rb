# frozen_string_literal: true

require 'spree/testing_support/factories/taxonomy_factory'

FactoryBot.define do
  factory :taxon, class: 'Solidus::Taxon' do
    name { 'Ruby on Rails' }
    taxonomy
    parent_id { nil }
  end
end
