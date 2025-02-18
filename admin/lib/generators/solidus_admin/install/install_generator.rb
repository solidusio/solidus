# frozen_string_literal: true

module SolidusAdmin
  module Generators
    class InstallGenerator < Rails::Generators::Base
      class_option :lookbook, type: :boolean, default: !!ENV["SOLIDUS_ADMIN_LOOKBOOK"], desc: "Install Lookbook for component previews"
      class_option :tailwind, type: :boolean, default: false, desc: "Install TailwindCSS for custom components"

      source_root "#{__dir__}/templates"

      def install_solidus_core_support
        route <<~RUBY
          mount SolidusAdmin::Engine, at: '#{solidus_mount_point}admin', constraints: ->(req) {
            req.cookies['solidus_admin'] != 'false' &&
            req.params['solidus_admin'] != 'false'
          }
        RUBY
      end

      def copy_initializer
        template "config/initializers/solidus_admin.rb.tt", "config/initializers/solidus_admin.rb"
      end

      def ignore_tailwind_build_files
        append_file(".gitignore", "app/assets/builds/solidus_admin/") if File.exist?(Rails.root.join(".gitignore"))
      end

      def build_tailwind
        rake "solidus_admin:tailwindcss:install" if options[:tailwind]
      end

      def install_lookbook
        return unless options[:lookbook]

        gem_group :development, :test do
          gem "lookbook"
          gem "listen"
          gem "actioncable"
        end

        execute_command :bundle, :install

        route "mount Lookbook::Engine, at: '#{solidus_mount_point}lookbook' if Rails.env.development?"
      end

      private

      def solidus_mount_point
        mount_point = Spree::Core::Engine.routes.find_script_name({})
        mount_point += "/" unless mount_point.end_with?("/")
        mount_point
      end
    end
  end
end
