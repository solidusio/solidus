module SpreeI18n
  module Generators
    class InstallGenerator < Rails::Generators::Base
      class_option :auto_run_migrations, :type => :boolean, :default => true

      def add_javascripts
        append_file "app/assets/javascripts/admin/all.js", "//= require admin/spree_i18n\n"
        append_file "app/assets/javascripts/store/all.js", "//= require store/spree_i18n\n"
      end

      def add_stylesheets
        inject_into_file "app/assets/stylesheets/admin/all.css", " *= require admin/spree_i18n\n",
          :before => /\*\//, :verbose => true
      end

      def add_migrations
        run 'rake railties:install:migrations FROM=spree_i18n'
      end

      def run_migrations
         if options[:auto_run_migrations] || ['', 'y', 'Y'].include?(ask "Would you like to run the migrations now? [Y/n]")
           run 'rake db:migrate'
         else
           puts "Skiping rake db:migrate, don't forget to run it!"
         end
      end
    end
  end
end
