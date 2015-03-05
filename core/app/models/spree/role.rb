module Spree
  class Role < Spree::Base
    has_many :role_users, class_name: "Spree::RoleUser"
    has_many :users, through: :role_users

    def admin?
      name == "admin"
    end
  end
end
