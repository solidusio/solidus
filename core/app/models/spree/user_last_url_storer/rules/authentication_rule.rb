# frozen_string_literal: true

module Spree
  class UserLastUrlStorer
    module Rules
      # This is the basic rule that ships with Solidus that avoids storing in
      # session the current path for login/loout/signup routes, avoiding possibly
      # infinte redirects.
      module AuthenticationRule
        AUTHENTICATION_ROUTES = %w[spree_signup_path spree_login_path spree_logout_path]

        extend self

        def match?(controller)
          full_path = controller.request.fullpath
          disallowed_urls(controller).include?(full_path)
        end

        private

        def disallowed_urls(controller)
          @disallowed_urls ||= {}
          @disallowed_urls[controller.controller_name] ||= begin
            [].tap do |disallowed_urls|
              AUTHENTICATION_ROUTES.each do |route|
                if controller.respond_to?(route)
                  disallowed_urls << controller.send(route)
                end
              end
            end.map! { |url| url[/\/\w+$/] }
          end
        end
      end
    end
  end
end
