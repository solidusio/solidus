module Spree
  class RoleUser < ActiveRecord::Base
    self.table_name = "spree_roles_users"
    belongs_to :role, class_name: "Spree::Role"
    belongs_to :user, class_name: Spree.user_class.to_s

    after_save :generate_admin_api_key

    private

    def generate_admin_api_key
      if role.admin? && user.respond_to?(:spree_api_key) && !user.spree_api_key
        user.generate_spree_api_key!
      end
    end
  end
end
