module Spree
  module Core
    module ControllerHelpers
      module LoginRedirector

        def redirect_unauthorized_access
          if try_spree_current_user
            flash[:error] = Spree.t(:authorization_failure)
            redirect_to '/unauthorized'
          else
            store_location
            if respond_to?(:spree_login_path)
              redirect_to spree_login_path
            else
              redirect_to '/unauthorized'
            end
          end
        end

      end
    end
  end
end
