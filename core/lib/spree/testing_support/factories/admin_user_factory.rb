# frozen_string_literal: true

FactoryBot.define do
  # Builds an instance of `Spree.admin_user_class` carrying the admin role.
  #
  # `Spree.admin_user_class` falls back to `Spree.user_class`, so this behaves
  # exactly like a `:user` with the admin role until a host application
  # configures a dedicated admin user model.
  factory :admin_user, class: Spree::AdminUserClassHandle.new do
    email { generate(:email) }
    password { "secret" }
    password_confirmation { password }

    after(:create) do |user, _|
      admin_role = Spree::Role.find_by(name: "admin") || create(:role, name: "admin")
      user.spree_roles << admin_role
    end
  end
end
