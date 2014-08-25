module Spree
  Product.class_eval do
    translates :name, :description, :meta_description, :meta_keywords, :slug,
      :fallbacks_for_empty_translations => true
    include SpreeI18n::Translatable

    # N+1 problem
    default_scope -> { includes(:translations).references(:translations) } if method_defined?(:translations) && connection.table_exists?(self.translations_table_name)
    default_scope -> { includes(master: [:prices, :images]).references(master: [:prices, :images]) }

    def duplicate_extra(old_product)
      duplicate_translations(old_product)
    end

    private

    def duplicate_translations(old_product)
      old_product.translations.each do |translation|
        self.translations << translation.dup
      end
    end
  end
end
