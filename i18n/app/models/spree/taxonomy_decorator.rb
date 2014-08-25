module Spree
  Taxonomy.class_eval do
    translates :name, :fallbacks_for_empty_translations => true
    include SpreeI18n::Translatable

    # N+1 problem
    default_scope -> { 
      includes(:translations, root: [:translations, children: [:translations]] ).
      references(:translations, root: [:translations, children: [:translations]])
    } if method_defined?(:translations) && connection.table_exists?(self.translations_table_name)
  end
end
