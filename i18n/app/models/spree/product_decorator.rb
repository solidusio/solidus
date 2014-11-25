module Spree
  Product.class_eval do
    translates :name, :description, :meta_description, :meta_keywords, :slug,
      fallbacks_for_empty_translations: true

    friendly_id :slug_candidates, use: [:history, :globalize]

    include SpreeI18n::Translatable

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
