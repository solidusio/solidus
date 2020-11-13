# frozen_string_literal: true

require 'spree/testing_support'
Spree::TestingSupport.deprecate_cherry_picking_factory_bot_files

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
