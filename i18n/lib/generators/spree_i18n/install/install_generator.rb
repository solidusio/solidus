module SpreeI18n
  module Generators
    class InstallGenerator < Rails::Generators::Base
      class_option :auto_run_migrations, type: :boolean, default: true

      def add_javascripts
        append_file 'vendor/assets/javascripts/spree/backend/all.js', "//= require spree/backend/spree_i18n\n"
        append_file 'vendor/assets/javascripts/spree/frontend/all.js', "//= require spree/frontend/spree_i18n\n"
      end

      def add_migrations
        run 'bundle exec rake railties:install:migrations FROM=spree_i18n'
      end

      def run_migrations
        if options[:auto_run_migrations] || ['', 'y', 'Y'].include?(ask 'Would you like to run the migrations now? [Y/n]')
          run 'bundle exec rake db:migrate'
        else
          puts "Skiping rake db:migrate, don't forget to run it!"
        end
      end
    end
  end
end
