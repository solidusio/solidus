require 'factory_bot'
require 'ffaker'

FactoryBot.define do
  sequence(:random_code)        { FFaker::Lorem.characters(10) }
  sequence(:random_description) { FFaker::Lorem.paragraphs(1 + Kernel.rand(5)).join("\n") }
  sequence(:random_email)       { FFaker::Internet.email }
  sequence(:random_string)      { FFaker::Lorem.sentence }
  sequence(:sku) { |n| "SKU-#{n}" }
end
