initializer "spree_authentication.rb", <<~RUBY
  # Please replace this module with your own implementation of
  # ApplicationController#spree_current_user.
  #
  # The current setup will allow doing guest checkouts.
  ActiveSupport.on_load(:action_controller) do
    def spree_current_user
      # Define here your custom logic for retrieving the current user
      nil
    end
  end
RUBY

create_file "app/views/spree/admin/shared/_navigation_footer.html.erb", <<~ERB
  <!-- Add here your login/logout links in 'app/views/spree/admin/shared/_navigation_footer.html.erb'. -->
ERB
