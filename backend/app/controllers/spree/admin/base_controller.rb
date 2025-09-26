# frozen_string_literal: true

module Spree
  module Admin
    class BaseController < Spree::BaseController
      helper "spree/admin/navigation"
      layout "spree/layouts/admin"

      before_action :authorize_admin

      respond_to :html

      private

      # Overrides ControllerHelpers::Common
      # We want the admin's locale selection to be different than that on the frontend
      include SetsUserLanguageLocaleKey

      def action
        params[:action].to_sym
      end

      def authorize_admin
        record = if respond_to?(:model_class, true) && model_class
          model_class
        else
          controller_name.to_sym
        end
        authorize! :admin, record
        authorize! action, record
      end

      # Need to generate an API key for a user due to some backend actions
      # requiring authentication to the Spree API
      def generate_admin_api_key
        if (user = spree_current_user) && user.spree_api_key.blank?
          user.generate_spree_api_key!
        end
      end

      def flash_message_for(object, event_sym)
        resource_desc = object.class.model_name.human
        resource_desc += " \"#{object.name}\"" if object.respond_to?(:name) && object.name.present?
        t(event_sym, resource: resource_desc, scope: "spree")
      end

      def render_js_for_destroy
        render partial: "/spree/admin/shared/destroy"
      end

      def config_locale
        Spree::Backend::Config[:locale]
      end

      def lock_order
        Spree::OrderMutex.with_lock!(@order) { yield }
      rescue Spree::OrderMutex::LockFailed
        flash[:error] = t("spree.order_mutex_admin_error")
        redirect_to order_mutex_redirect_path
      end

      def order_mutex_redirect_path
        edit_admin_order_path(@order)
      end

      def resource_not_found(flash_class:, redirect_url:)
        flash[:error] = flash_message_for(flash_class.new, :not_found)
        redirect_to redirect_url
        nil
      end

      def handle_unauthorized_access
        if unauthorized_redirect
          instance_exec(&unauthorized_redirect)
        else
          Spree::Backend::Config.unauthorized_redirect_handler_class.new(self).call
        end
      end
    end
  end
end
