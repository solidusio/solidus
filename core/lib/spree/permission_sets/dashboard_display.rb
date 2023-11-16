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
          Spree.deprecator.warn "The #{self.class.name} module is deprecated. " \
            "If you still use dashboards, please copy all controllers and views from #{self.class.name} to your application."
          can [:admin, :home], :dashboards
      end
    end
  end
end
