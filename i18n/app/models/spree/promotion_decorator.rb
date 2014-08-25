module Spree
  Promotion.class_eval do
    translates :name, :description, :fallbacks_for_empty_translations => true
    include SpreeI18n::Translatable

    # N+1 problem
    default_scope -> { includes(:translations).references(:translations) } if method_defined?(:translations) && connection.table_exists?(self.translations_table_name)
  end
end
