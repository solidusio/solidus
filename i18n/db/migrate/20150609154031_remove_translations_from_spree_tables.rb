class RemoveTranslationsFromSpreeTables < ActiveRecord::Migration
  def up
    # Don't migrate if we still use Globalize, i.e. through spree_globalize Gem
    return if defined?(Globalize)

    %w(
      OptionType
      OptionValue
      ProductProperty
      Product
      Promotion
      Property
      Store
      Taxon
      Taxonomy
    ).each do |class_name|
      migrate_translation_data!(class_name)
    end
  end

  def down
    return if defined?(Globalize)
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def current_locale
    I18n.default_locale || 'en'
  end

  def migrate_translation_data!(class_name)
    klass = "Spree::#{class_name}".constantize
    table_name = klass.table_name
    singular_table_name = table_name.singularize

    return if !table_exists?(table_name) || !table_exists?("#{singular_table_name}_translations")

    # We can't rely on Globalize drop_translation_table! here,
    # because the Gem has been already removed, so we need to run custom SQL
    records = exec_query("SELECT * FROM #{singular_table_name}_translations WHERE locale = '#{current_locale}';")

    records.each do |record|
      id = record["#{singular_table_name}_id"]
      attributes = record.except(
        'id',
        "#{singular_table_name}_id",
        'locale',
        'deleted_at',
        'created_at',
        'updated_at'
      )
      object = if klass.respond_to?(:with_deleted)
                 klass.with_deleted.find(id)
               else
                 klass.find(id)
               end
      object.update_columns(attributes)
    end

    say "Migrated #{current_locale} translation for #{class_name} back into original table."

    drop_table "#{singular_table_name}_translations"
  end
end
