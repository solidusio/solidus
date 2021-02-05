# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

FactoryBot.define do
  factory :store, class: 'Spree::Store' do
    sequence(:code) { |i| "spree_#{i}" }
    sequence(:name) { |i| "Spree Test Store #{i}" }
    sequence(:url) { |i| "www.example#{i}.com" }
    mail_from_address { 'solidus@example.org' }
  end
end
