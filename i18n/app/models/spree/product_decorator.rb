module Spree
  Product.class_eval do
    translates :name, :description, :meta_description, :meta_keywords, :slug,
      fallbacks_for_empty_translations: true

    friendly_id :slug_candidates, use: [:history, :globalize]

    include SpreeI18n::Translatable

    # Allow to filter products through their translations, too
    def self.like_any(fields, values)
      translations = Spree::Product::Translation.arel_table

      joins(:translations).where(fields.map { |field|
        values.map { |value|
          translations[field].matches("%#{value}%").        # extension: match with translations under current locale
            or(arel_table[field].matches("%#{value}%"))     # compatible with original behaviour
        }.inject(:or)
      }.inject(:or).and(translations[:locale].eq(I18n.locale)))
    end

    def duplicate_extra(old_product)
      duplicate_translations(old_product)
    end

    private

    def duplicate_translations(old_product)
      old_product.translations.each do |translation|
        translation.slug = nil # slug must be regenerated
        self.translations << translation.dup
      end
    end
  end
end
