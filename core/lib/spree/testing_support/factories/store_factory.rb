# frozen_string_literal: true

FactoryBot.define do
  factory :store, class: 'Spree::Store' do
    sequence(:code) { |i| "spree_#{i}" }
    sequence(:name) { |i| "Spree Test Store #{i}" }
    sequence(:url) { |i| "www.example#{i}.com" }
    mail_from_address { 'spree@example.org' }
  end
end
