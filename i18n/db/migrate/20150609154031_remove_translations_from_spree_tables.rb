class RemoveTranslationsFromSpreeTables < ActiveRecord::Migration
  def up
    # Don't migrate if we still use Globalize, i.e. through spree_globalize Gem
    return if defined?(Globalize)

    %w[
      OptionType
      OptionValue
      ProductProperty
      Product
      Promotion
      Property
      Store
      Taxon
      Taxonomy
    ].each do |class_name|
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

  # We can't rely on Globalize drop_translation_table! here,
  # because the Gem has been already removed, so we need to run custom SQL
  def migrate_translation_data!(class_name)
    klass = "Spree::#{class_name}".constantize
    table_name = klass.table_name
    singular_table_name = table_name.singularize

    return if !table_exists?(table_name) || !table_exists?("#{singular_table_name}_translations")

    records = execute("
      SELECT *
      FROM #{singular_table_name}_translations
      WHERE locale = '#{current_locale}';
    ")

    records.each do |record|
      attributes = record.except(
        'id',
        "#{singular_table_name}_id",
        'locale',
        'deleted_at',
        'created_at',
        'updated_at'
      )
      execute("
        UPDATE #{table_name}
        SET (#{sql_update_values(attributes)})
        WHERE id=#{record['spree_#{table_name}_id']};
      ")
    end

    say "Migrated #{current_locale} translation for #{class_name} back into original table."

    drop_table "#{singular_table_name}_translations"
  end

  def sql_update_values(attributes)
    attributes.map do |key, value|
      "#{key} = '#{value}'"
    end.join(', ')
  end
end
