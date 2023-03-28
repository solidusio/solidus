# frozen_string_literal: true

FactoryBot.define do
  factory :taxonomy, class: 'Spree::Taxonomy' do
    sequence :name do |seq|
      "Brand #{seq}"
    end
  end
end
