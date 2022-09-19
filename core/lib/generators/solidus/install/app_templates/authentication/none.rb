initializer 'spree_no_authentication.rb', <<~RUBY
  # Please replace this module with your own implementation of
  # ApplicationController#spree_current_user.
  #
  # The current setup will allow doing guest checkouts and visitng
  # the /admin area without requiring any authentication.
  module SpreeNoAuthentication
    def self.install!
      # Set #spree_current_user to nil for all controllers
      ActiveSupport.on_load(:action_controller) do
        def spree_current_user
          nil
        end
      end

      # Re-raise the original authorization error on anauthorized access
      Rails.application.config.to_prepare do
        Spree::BaseController.unauthorized_redirect = -> { raise }
      end

      # Provide the "default" role with full permissions on everything
      Spree.config do |config|
        config.roles.assign_permissions :default, ['Spree::PermissionSets::SuperUser']
      end
    end

    install!
  end
RUBY

create_file 'app/views/spree/admin/shared/_navigation_footer.html.erb', ''
