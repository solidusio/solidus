# frozen_string_literal: true

module SolidusAdmin
  module Generators
    class InstallGenerator < Rails::Generators::Base
      class_option :lookbook, type: :boolean, default: !!ENV['SOLIDUS_ADMIN_LOOKBOOK'], desc: 'Install Lookbook for component previews'

      source_root "#{__dir__}/templates"

      def install_solidus_core_support
        route <<~RUBY
          mount SolidusAdmin::Engine, at: '/admin', constraints: ->(req) {
            req.cookies['solidus_admin'] != 'false'
          }
        RUBY
      end

      def copy_initializer
        copy_file "config/initializers/solidus_admin.rb"
      end

      def ignore_tailwind_build_files
        append_file(".gitignore", "app/assets/builds/solidus_admin/") if File.exist?(Rails.root.join(".gitignore"))
      end

      def build_tailwind
        rake "solidus_admin:tailwindcss:build"
      end

      def install_lookbook
        return unless options[:lookbook]

        gem_group :development, :test do
          gem "lookbook"
          gem "listen"
          gem "actioncable"
        end

        route "mount Lookbook::Engine, at: '/lookbook' if Rails.env.development?"
      end
    end
  end
end
