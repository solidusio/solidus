# frozen_string_literal: true

FactoryBot.define do
  factory :image, class: 'Spree::Image' do
    attachment { Spree::Core::Engine.root.join('lib', 'spree', 'testing_support', 'fixtures', 'blank.jpg').open }
  end
end
