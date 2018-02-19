# frozen_string_literal: true

module Spree
  module Admin
    class RootController < Spree::Admin::BaseController
      skip_before_action :authorize_admin

      def index
        redirect_to admin_root_redirect_path
      end

      private

      def admin_root_redirect_path
        if can?(:display, Spree::Order) && can?(:admin, Spree::Order)
          spree.admin_orders_path
        elsif can?(:admin, :dashboards) && can?(:home, :dashboards)
          spree.home_admin_dashboards_path
        else
          # Invoke the unauthorized redirect, which will ideally go to the login controller
          # of the users chosen authorization implimentation. For devise this is /admin/login.
          #
          # This is done so devise redirects back to this controller, instead of the one specified
          # below, so this controller can use the user that is required for the path to
          # be calculated.
          raise CanCan::AccessDenied
        end
      end
    end
  end
end
