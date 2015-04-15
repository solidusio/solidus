module Spree
  Store.class_eval do
    translates :name, :meta_description, :meta_keywords, :seo_title,
               fallbacks_for_empty_translations: true
    include SpreeI18n::Translatable
  end
end
