module Spree
  module Admin
    class RootController < Spree::Admin::BaseController
      skip_before_filter :authorize_admin

      def index
        redirect_to admin_root_redirect_path
      end

      protected

      def admin_root_redirect_path
        if can?(:display, Spree::Order) && can?(:admin, Spree::Order)
          spree.admin_orders_path
        else
          spree.home_admin_dashboards_path
        end
      end
    end
  end
end
