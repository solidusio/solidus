# frozen_string_literal: true

module SolidusAdmin
  module Generators
    class InstallGenerator < Rails::Generators::Base
      def install_solidus_core_support
        route <<~RUBY
          mount SolidusAdmin::Engine, at: '/admin', constraints: ->(req) {
            req.cookies['solidus_admin'] == 'true'
          }
        RUBY
      end
    end
  end
end
