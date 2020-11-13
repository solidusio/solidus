# frozen_string_literal: true

require 'spree/testing_support'
Spree::TestingSupport.deprecate_cherry_picking_factory_bot_files

FactoryBot.define do
  factory :taxon, class: 'Spree::Taxon' do
    name { 'Ruby on Rails' }
    taxonomy
    parent_id { nil }

    trait :with_icon do
      icon { Spree::Core::Engine.root.join('lib', 'spree', 'testing_support', 'fixtures', 'blank.jpg').open }
    end
  end
end
