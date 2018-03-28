# frozen_string_literal: true

require 'rails/generators/active_record/migration'

module Spree
  # @private
  class CustomUserGenerator < Rails::Generators::NamedBase
    include ActiveRecord::Generators::Migration

    desc "Set up a Solidus installation with a custom User class"

    source_root File.expand_path('templates', File.dirname(__FILE__))

    def check_for_constant
      klass
    rescue NameError
      @shell.say "Couldn't find #{class_name}. Are you sure that this class exists within your application and is loaded?", :red
      exit(1)
    end

    def generate
      migration_template 'migration.rb.tt', "db/migrate/add_spree_fields_to_custom_user_table.rb"
      template 'authentication_helpers.rb.tt', "lib/spree/authentication_helpers.rb"

      file_action = File.exist?('config/initializers/spree.rb') ? :append_file : :create_file
      send(file_action, 'config/initializers/spree.rb') do
        "Rails.application.config.to_prepare do\n  require_dependency 'spree/authentication_helpers'\nend\n"
      end

      gsub_file 'config/initializers/spree.rb', /Spree\.user_class.?=.?.+$/, %{Spree.user_class = "#{class_name}"}
    end

    private

    def klass
      class_name.constantize
    end

    def table_name
      klass.table_name
    end
  end
end
