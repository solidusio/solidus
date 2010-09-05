module SpreeI18n
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc "Installs Spree locale files into your project"

      # test method - later we'll copy only the requested locales
      def copy_initializer
        directory "config/locales"
      end
    end
  end
end