# frozen_string_literal: true

require 'spree/testing_support/factories/taxonomy_factory'

FactoryBot.define do
  factory :taxon, class: 'Spree::Taxon' do
    name { 'Ruby on Rails' }
    taxonomy
    parent_id { nil }

    trait :with_icon do
      icon { Spree::Core::Engine.root.join('spec', 'fixtures', 'thinking-cat.jpg').open }
    end
  end
end
