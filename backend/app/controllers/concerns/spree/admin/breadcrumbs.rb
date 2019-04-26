# frozen_string_literal: true

module Spree
  module Admin
    module Breadcrumbs
      def add_breadcrumb(name, path = nil)
        @admin_breadcrumbs ||= []
        @admin_breadcrumbs << [name, path]
      end

      # Shared breadcrumbs

      def set_user_breadcrumbs
        add_breadcrumb plural_resource_name(Spree::LegacyUser), spree.admin_users_path
        add_breadcrumb @user.email, edit_admin_user_url(@user) if @user && !@user.new_record?
      end

      def set_order_breadcrumbs
        add_breadcrumb plural_resource_name(Spree::Order), spree.admin_orders_path
        add_breadcrumb "##{@order.number}", spree.edit_admin_order_path(@order) if @order && !@order.new_record?
      end

      def set_product_breadcrumbs
        add_breadcrumb plural_resource_name(Spree::Product), spree.admin_products_path
        add_breadcrumb @product.name, spree.admin_product_path(@product) if @product && !@product.new_record?
      end
    end
  end
end
