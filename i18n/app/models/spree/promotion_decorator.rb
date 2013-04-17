module Spree
  Promotion.class_eval do
    translates :name, :description
    attr_accessible :translations_attributes
    accepts_nested_attributes_for :translations
  end
end
