# frozen_string_literal: true

module SolidusPromotions
  module Generators
    class InstallGenerator < Rails::Generators::Base
      class_option :auto_run_migrations, type: :boolean, default: false
      source_root File.expand_path("templates", __dir__)

      def self.exit_on_failure?
        true
      end

      def copy_initializer
        template "initializer.rb", "config/initializers/solidus_promotions.rb"
      end

      def add_migrations
        run "bin/rails railties:install:migrations FROM=solidus_promotions"
      end

      def modify_spree_initializer
        spree_rb_path = "config/initializers/spree.rb"
        new_content = <<-RUBY.gsub(/^ {8}/, "")
          # Make sure we use Spree::SimpleOrderContents
          # Spree::Config.order_contents_class = "Spree::SimpleOrderContents"
          # Set the promotion configuration to ours
          # Spree::Config.promotions = SolidusPromotions.configuration
        RUBY
        insert_into_file spree_rb_path, new_content, after: "Spree.config do |config|\n"
      end

      def mount_engine
        inject_into_file "config/routes.rb",
          "  mount SolidusPromotions::Engine => '/'\n",
          before: /  mount Spree::Core::Engine.*/,
          verbose: true
      end

      def run_migrations
        run_migrations = options[:auto_run_migrations] || ["", "y", "Y"].include?(ask("Would you like to run the migrations now? [Y/n]"))
        if run_migrations
          run "bin/rails db:migrate"
        else
          puts "Skipping bin/rails db:migrate, don't forget to run it!"
        end
      end

      def explain_promotion_config
        say "SolidusPromotions is now installed. You can configure it by editing the initializer at `config/initializers/solidus_promotions.rb`."
        say "By default, it is not activated. In order to activate it, you need to set `Spree::Config.promotions` to `SolidusPromotions.configuration`" \
          "in your `config/initializers/spree.rb` file."
        say "If you have been running the legacy promotion system, we recommend converting your existing promotions using the `solidus_promotions:migrate_existing_promotions` rake task."
      end
    end
  end
end
