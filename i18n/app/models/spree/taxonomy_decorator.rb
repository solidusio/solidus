module Spree
  Taxonomy.class_eval do
    translates :name
    include SpreeI18n::Translatable
  end
end
