module Solidus
  class RoleUser < Solidus::Base
    self.table_name = "solidus_roles_users"
    belongs_to :role, class_name: "Solidus::Role"
    belongs_to :user, class_name: Solidus::UserClassHandle.new

    after_create :auto_generate_solidus_api_key

    private

    def auto_generate_solidus_api_key
      user.try!(:auto_generate_solidus_api_key)
    end
  end
end
