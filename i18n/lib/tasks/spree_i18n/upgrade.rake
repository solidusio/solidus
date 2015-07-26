require 'fileutils'

namespace :spree_i18n do
  desc 'Upgrades to version without globalize.'
  task upgrade: :environment do
    files = %w(
      add_translations_to_main_models
      add_translations_to_product_permalink
      add_translations_to_option_value
      rename_activator_translations_to_promotion_translations
      update_spree_product_translations
      add_translations_to_product_properties
      remove_null_constraints_from_spree_tables
      add_deleted_at_to_translation_tables
      add_translations_to_store
    ).collect do |file_name|
      Dir.glob Rails.root.join('db', 'migrate', "*_#{file_name}*.rb")
    end.flatten

    # Delete old migrations
    FileUtils.rm files

    # Install new migrations
    Rake::Task['spree_i18n:install:migrations'].invoke

    puts <<-DESC
Upgraded migrations successfully.

Now please remove these lines from your vendor/assets folder:

From `vendor/assets/javascripts/spree/backend/all.js`

    //= require spree/backend/spree_i18n

and from `vendor/assets/stylesheets/spree/backend/all.css`

    *= require spree/backend/spree_i18n

Don't forget to run `rake db:migrate` now.

DESC
  end
end
