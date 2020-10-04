# frozen_string_literal: true

module Spree
  class RoleUser < Spree::Base
    self.table_name = "spree_roles_users"
    belongs_to :role, class_name: "Spree::Role", optional: true
    belongs_to :user, class_name: Spree::UserClassHandle.new, optional: true

    after_create :auto_generate_spree_api_key

    validates_uniqueness_of :role_id, scope: :user_id

    private

    def auto_generate_spree_api_key
      user.try!(:auto_generate_spree_api_key)
    end
  end
end
