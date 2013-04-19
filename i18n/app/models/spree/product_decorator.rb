module Spree
  Product.class_eval do
    translates :name, :description, :meta_description, :meta_keywords, :fallbacks_for_empty_translations => true
    include SpreeI18n::Translatable
  end
end
