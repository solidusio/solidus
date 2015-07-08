module Spree
  module Admin
    class Ability
      include CanCan::Ability

      def initialize user
        # TODO: this could be extracted out to a sub role eventually
        if user.has_spree_role?(:dashboard_display)
          can [:admin, :home], :dashboards
        end
      end
    end
  end
end
