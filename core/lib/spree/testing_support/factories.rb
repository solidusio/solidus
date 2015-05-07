require 'factory_girl'

Dir["#{File.dirname(__FILE__)}/factories/**"].each do |f|
  require File.expand_path(f)
end

require_relative "fixtures"

FactoryGirl.define do
  sequence(:random_string)      { Faker::Lorem.sentence }
  sequence(:random_description) { Faker::Lorem.paragraphs(1 + Kernel.rand(5)).join("\n") }
  sequence(:random_email)       { Faker::Internet.email }

  sequence(:sku) { |n| "SKU-#{n}" }
  sequence(:random_code)        { Faker::Lorem.characters(10) }
end
