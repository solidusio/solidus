# frozen_string_literal: true

module Spree
  module PermissionSets
    # Permissions for viewing the admin dashboard.
    #
    # Roles with this permission set will be able to view the admin dashboard,
    # which may or not contain sensitive information depending on
    # customizations.
    class DashboardDisplay < PermissionSets::Base
      def activate!
          can [:admin, :home], :dashboards
      end
    end
  end
end
