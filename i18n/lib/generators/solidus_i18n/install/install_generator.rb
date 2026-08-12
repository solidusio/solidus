# frozen_string_literal: true

module SolidusI18n
  module Generators
    class InstallGenerator < Rails::Generators::Base
      class_option :auto_run_migrations, type: :boolean, default: false
      source_root File.expand_path("templates", __dir__)

      def self.exit_on_failure?
        true
      end

      def copy_initializer
        template "initializer.rb", "config/initializers/solidus_i18n.rb"
      end
    end
  end
end
