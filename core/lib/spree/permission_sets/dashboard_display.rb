# frozen_string_literal: true

module Solidus
  module PermissionSets
    class DashboardDisplay < PermissionSets::Base
      def activate!
          can [:admin, :home], :dashboards
      end
    end
  end
end
