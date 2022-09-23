# frozen_string_literal: true

module Spree
  class Migrations
    attr_reader :config, :engine_name

    # Takes the engine config block and engine name
    def initialize(config, engine_name)
      @config, @engine_name = config, engine_name
    end

    # Puts warning when any engine migration is not present on the Rails app
    # db/migrate dir
    #
    # First split:
    #
    #   ["20131128203548", "update_name_fields_on_spree_credit_cards.spree.rb"]
    #
    # Second split should give the engine_name of the migration
    #
    #   ["update_name_fields_on_spree_credit_cards", "spree.rb"]
    #
    # Shouldn't run on test mode because migrations inside engine don't have
    # engine name on the file name
    def check
      return unless File.directory?(app_dir)
      return if missing_migrations.empty?
      return if ENV['SOLIDUS_SKIP_MIGRATIONS_CHECK']

      prefix = "[WARNING #{engine_name.capitalize}]"
      warn <<~WARN
        #{prefix} Missing migrations.
        #{missing_migrations.map {|m| "#{prefix} - #{m}"}.join("\n")}
        #{prefix}
        #{prefix} Run `bin/rails railties:install:migrations` to get them.
        #{prefix} You can silence thi warning by setting the environment
        #{prefix} variable SOLIDUS_SKIP_MIGRATIONS_CHECK.'
      WARN
    end

    def missing_migrations
      @missing_migrations ||=
        begin
          engine_in_app = app_migrations.map do |file_name|
            name, engine = file_name.split(".", 2)
            next unless match_engine?(engine)
            name
          end.compact

          engine_migrations.sort - engine_in_app.sort
        end
    end

    private

    def engine_migrations
      Dir.entries(engine_dir).map do |file_name|
        name = file_name.split("_", 2).last.split(".", 2).first
        name.empty? ? next : name
      end.compact! || []
    end

    def app_migrations
      Dir.entries(app_dir).map do |file_name|
        next if [".", ".."].include? file_name
        name = file_name.split("_", 2).last
        name.empty? ? next : name
      end.compact! || []
    end

    def app_dir
      Spree::Config.migration_path
    end

    def engine_dir
      "#{config.root}/db/migrate"
    end

    def match_engine?(engine)
      if engine_name == "spree"
        # Avoid stores upgrading from 1.3 getting wrong warnings
        ["spree.rb", "spree_promo.rb"].include? engine
      else
        engine == "#{engine_name}.rb"
      end
    end
  end
end
