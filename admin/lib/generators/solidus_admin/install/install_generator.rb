# frozen_string_literal: true

module SolidusAdmin
  module Generators
    class InstallGenerator < Rails::Generators::Base
      def install_solidus_core_support
        route "mount SolidusAdmin::Engine, at: '/solidus_admin'"
      end
    end
  end
end
