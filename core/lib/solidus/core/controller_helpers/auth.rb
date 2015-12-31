module Solidus
  module Core
    module ControllerHelpers
      module Auth
        extend ActiveSupport::Concern

        # @!attribute [rw] unauthorized_redirect
        #   @!scope class
        #   Extension point for overriding behaviour of access denied errors.
        #   Default behaviour is to redirect to "/unauthorized" with a flash
        #   message.
        #   @return [Proc] action to take when access denied error is raised.

        included do
          before_filter :set_guest_token
          helper_method :try_solidus_current_user

          class_attribute :unauthorized_redirect
          self.unauthorized_redirect = -> do
            flash[:error] = Solidus.t(:authorization_failure)
            redirect_to "/unauthorized"
          end

          rescue_from CanCan::AccessDenied do
            instance_exec &unauthorized_redirect
          end
        end

        # Needs to be overriden so that we use Solidus's Ability rather than anyone else's.
        def current_ability
          @current_ability ||= Solidus::Ability.new(try_solidus_current_user)
        end

        def redirect_back_or_default(default)
          redirect_to(session["solidus_user_return_to"] || default)
          session["solidus_user_return_to"] = nil
        end

        def set_guest_token
          unless cookies.signed[:guest_token].present?
            cookies.permanent.signed[:guest_token] = SecureRandom.urlsafe_base64(nil, false)
          end
        end

        def store_location
          # disallow return to login, logout, signup pages
          authentication_routes = [:solidus_signup_path, :solidus_login_path, :solidus_logout_path]
          disallowed_urls = []
          authentication_routes.each do |route|
            if respond_to?(route)
              disallowed_urls << send(route)
            end
          end

          disallowed_urls.map!{ |url| url[/\/\w+$/] }
          unless disallowed_urls.include?(request.fullpath)
            session['solidus_user_return_to'] = request.fullpath.gsub('//', '/')
          end
        end

        # proxy method to *possible* solidus_current_user method
        # Authentication extensions (such as solidus_auth_devise) are meant to provide solidus_current_user
        def try_solidus_current_user
          # This one will be defined by apps looking to hook into Solidus
          # As per authentication_helpers.rb
          if respond_to?(:solidus_current_user)
            solidus_current_user
          # This one will be defined by Devise
          elsif respond_to?(:current_solidus_user)
            current_solidus_user
          else
            nil
          end
        end
      end
    end
  end
end
