module Spree
  Product.class_eval do
    translates :name, :description, :meta_description, :meta_keywords, :slug,
      fallbacks_for_empty_translations: true

    friendly_id :slug_candidates, use: [:history, :globalize]

    include SpreeI18n::Translatable

    translation_class.class_eval do
      # Paranoia soft-deletes the associated records only if they are paranoid themselves.
      acts_as_paranoid

      # Paranoid sets the default scope and Globalize rewrites all query methods.
      # Therefore we prefer to unset the default_scopes over injecting 'unscope'
      # in every Globalize query method.
      self.default_scopes = []

      # Punch slug on every translation to allow reuse of original
      after_destroy :punch_slug

      def punch_slug
        update(slug: "#{Time.now.to_i}_#{slug}")
      end
    end

    # Don't punch slug on original product as it prevents bulk deletion.
    # Also we don't need it, as it is translated.
    def punch_slug; end

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
