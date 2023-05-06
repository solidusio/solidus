# frozen_string_literal: true

module Spree
  class Role < Spree::Base
    has_many :role_users, class_name: "Spree::RoleUser", dependent: :destroy
    has_many :users, through: :role_users

    validates_uniqueness_of :name, case_sensitive: true

    def admin?
      name == "admin"
    end

    def permission_sets
      Spree::Config.roles.roles[name.to_s].permission_sets.to_a
    end
  end
end
