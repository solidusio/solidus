module Spree
  module Admin
    class BaseController < Solidus::BaseController
      helper 'solidus/admin/navigation'
      helper 'solidus/admin/tables'
      layout '/solidus/layouts/admin'

      before_action :authorize_admin

      private

        def action
          params[:action].to_sym
        end

        def authorize_admin
          if respond_to?(:model_class, true) && model_class
            record = model_class
          else
            record = controller_name.to_sym
          end
          authorize! :admin, record
          authorize! action, record
        end

        # Need to generate an API key for a user due to some backend actions
        # requiring authentication to the Spree API
        def generate_admin_api_key
          if (user = try_spree_current_user) && user.spree_api_key.blank?
            user.generate_spree_api_key!
          end
        end

        def flash_message_for(object, event_sym)
          resource_desc  = object.class.model_name.human
          resource_desc += " \"#{object.name}\"" if object.respond_to?(:name) && object.name.present?
          Solidus.t(event_sym, :resource => resource_desc)
        end

        def render_js_for_destroy
          render :partial => '/solidus/admin/shared/destroy'
        end

        # Index request for JSON needs to pass a CSRF token in order to prevent JSON Hijacking
        def check_json_authenticity
          return unless request.format.js? or request.format.json?
          return unless protect_against_forgery?
          auth_token = params[request_forgery_protection_token]
          unless (auth_token and form_authenticity_token == URI.unescape(auth_token))
            raise(ActionController::InvalidAuthenticityToken)
          end
        end

        def config_locale
          Solidus::Backend::Config[:locale]
        end

        def lock_order
          OrderMutex.with_lock!(@order) { yield }
        rescue Solidus::OrderMutex::LockFailed => e
          flash[:error] = Solidus.t(:order_mutex_admin_error)
          redirect_to order_mutex_redirect_path
        end

        def order_mutex_redirect_path
          edit_admin_order_path(@order)
        end
    end
  end
end
