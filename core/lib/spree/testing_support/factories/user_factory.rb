# frozen_string_literal: true

require 'spree/testing_support/sequences'
require 'spree/testing_support/factories/role_factory'
require 'spree/testing_support/factories/address_factory'

FactoryBot.define do
  factory :user, class: Spree::UserClassHandle.new do
    email { generate(:email) }
    password { 'secret' }
    password_confirmation { password }

    trait :with_api_key do
      after(:create) do |user, _|
        user.generate_spree_api_key!
      end
    end

    factory :admin_user do
      after(:create) do |user, _|
        admin_role = Spree::Role.find_by(name: 'admin') || create(:role, name: 'admin')
        user.spree_roles << admin_role
      end
    end

    factory :user_with_addresses do |_u|
      bill_address
      ship_address
    end
  end
end
