# frozen_string_literal: true

FactoryBot.define do
  factory :property, class: 'Spree::Property' do
    name { 'baseball_cap_color' }
    presentation { 'cap color' }
  end
end
