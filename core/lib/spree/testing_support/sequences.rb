require 'factory_girl'

FactoryGirl.define do
  sequence(:random_code)        { Faker::Lorem.characters(10) }
  sequence(:random_description) { Faker::Lorem.paragraphs(1 + Kernel.rand(5)).join("\n") }
  sequence(:random_email)       { Faker::Internet.email }
  sequence(:random_string)      { Faker::Lorem.sentence }
  sequence(:sku) { |n| "SKU-#{n}" }
end
