# frozen_string_literal: true

FactoryBot.define do
  factory :image, class: 'Spree::Image' do
    attachment { File.new(Spree::Core::Engine.root + 'spec/fixtures/thinking-cat.jpg') }
  end
end
