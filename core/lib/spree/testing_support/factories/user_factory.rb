# frozen_string_literal: true

FactoryBot.define do
  factory :user, class: Spree::UserClassHandle.new do
    email { generate(:email) }
    password { "secret" }
    password_confirmation { password }

    trait :with_api_key do
      after(:create) do |user, _|
        user.generate_spree_api_key!
      end
    end

    trait :with_orders do
      after(:create) do |user, _|
        create(:order, user:)
      end
    end

    factory :admin_user do
      after(:create) do |user, _|
        admin_role = Spree::Role.find_by(name: "admin") || create(:role, name: "admin")
        user.spree_roles << admin_role
      end
    end

    factory :limited_admin_user do
      transient do
        sequence(:role) { |n| "spree-limited-admin-role-#{n}" }
        permissions { [] }
      end

      after :create do |record, evaluator|
        permission_sets = evaluator.permissions.map(&:to_s)

        Spree.config do
          _1.roles.assign_permissions evaluator.role.to_sym, permission_sets
        end

        role = Spree::Role.find_or_create_by!(name: evaluator.role)
        permission_sets.each do |set|
          privilege =
            set.downcase.ends_with?("management") ? :management : :display

          role.permission_sets << Spree::PermissionSet.create!(
            name: set,
            set:,
            category: :test_category,
            privilege:
          )
        end

        record.spree_roles << role
      end
    end

    factory :user_with_addresses do |_u|
      bill_address
      ship_address
    end
  end
end
