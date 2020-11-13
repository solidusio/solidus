# frozen_string_literal: true

require 'spree/testing_support'
Spree::TestingSupport.deprecate_cherry_picking_factory_bot_files

FactoryBot.define do
  factory :image, class: 'Spree::Image' do
    attachment { Spree::Core::Engine.root.join('lib', 'spree', 'testing_support', 'fixtures', 'blank.jpg').open }
  end
end
