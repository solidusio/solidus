# frozen_string_literal: true

FactoryBot.define do
  factory :taxonomy, class: 'Solidus::Taxonomy' do
    name { 'Brand' }
  end
end
