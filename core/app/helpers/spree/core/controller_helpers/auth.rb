# frozen_string_literal: true

require 'cancan'

module Spree
  module Core
    module ControllerHelpers
      module Auth
        extend ActiveSupport::Concern

        # @!attribute [rw] unauthorized_redirect
        #   @!scope class
        #   Extension point for overriding behaviour of access denied errors.
        #   Default behaviour is to redirect back or to "/unauthorized" with a flash
        #   message.
        #   @return [Proc] action to take when access denied error is raised.

        included do
          before_action :set_guest_token
          helper_method :spree_current_user

          class_attribute :unauthorized_redirect
          deprecate :unauthorized_redirect= => "Use a custom Spree::Config.unauthorized_redirect_handler_class instead", :deprecator => Spree.deprecator

          rescue_from CanCan::AccessDenied, with: :handle_unauthorized_access
        end

        # Needs to be overriden so that we use Spree's Ability rather than anyone else's.
        def current_ability
          @current_ability ||= Spree::Ability.new(spree_current_user)
        end

        def redirect_back_or_default(default)
          redirect_to(session["spree_user_return_to"] || default)
          session["spree_user_return_to"] = nil
        end

        def set_guest_token
          if cookies.signed[:guest_token].blank?
            cookies.permanent.signed[:guest_token] = Spree::Config[:guest_token_cookie_options].merge(
              value: SecureRandom.urlsafe_base64(nil, false),
              httponly: true
            )
          end
        end

        def store_location
          Spree::UserLastUrlStorer.new(self).store_location
        end

        # Auth extensions are expected to define it, otherwise it's a no-op
        def spree_current_user
          defined?(super) ? super : nil
        end

        def handle_unauthorized_access
          if unauthorized_redirect
            instance_exec(&unauthorized_redirect)
          else
            Spree::Config.unauthorized_redirect_handler_class.new(self).call
          end
        end
      end
    end
  end
end
