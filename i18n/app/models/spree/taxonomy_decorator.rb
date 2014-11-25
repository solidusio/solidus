module Spree
  Taxonomy.class_eval do
    translates :name, :fallbacks_for_empty_translations => true
    include SpreeI18n::Translatable
  end
end
