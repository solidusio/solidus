# frozen_string_literal: true

module Spree
  class Role < Spree::Base
    has_many :role_users, class_name: "Spree::RoleUser", dependent: :destroy
    has_many :users, through: :role_users

    validates :name, presence: true, uniqueness: { case_sensitive: true, allow_blank: true }

    def admin?
      name == "admin"
    end
  end
end
