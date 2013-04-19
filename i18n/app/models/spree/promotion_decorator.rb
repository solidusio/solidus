module Spree
  Promotion.class_eval do
    translates :name, :description
    include SpreeI18n::Translatable
  end
end
