# frozen_string_literal: true

FactoryBot.define do
  factory :image, class: 'Spree::Image' do
    attachment { Spree::Core::Engine.root.join('lib', 'fixtures', 'thinking-cat.jpg').open }
  end
end
