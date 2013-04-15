module Spree
  Product.class_eval do
    translates :name, :description, :meta_description, :meta_keywords

    attr_accessible :translations_attributes

    accepts_nested_attributes_for :translations
  end
end
