module SolidusI18n
  module Generators
    class InstallGenerator < Rails::Generators::Base
      class_option :auto_run_migrations, type: :boolean, default: true

      def add_javascripts
        append_file 'vendor/assets/javascripts/spree/backend/all.js',
          "//= require spree/backend/solidus_i18n\n"
        append_file 'vendor/assets/javascripts/spree/frontend/all.js',
          "//= require spree/frontend/solidus_i18n\n"
      end

      def add_migrations
        run 'bin/rake solidus_i18n:install:migrations'
      end

      def run_migrations
        if options[:auto_run_migrations] ||
          ['', 'y', 'Y'].include?(ask('Would you like to run the migrations now? [Y/n]'))
          run 'bin/rake db:migrate'
        else
          puts "Skiping rake db:migrate, don't forget to run it!"
        end
      end
    end
  end
end
