module Spree
  Taxon.class_eval do
    translates :name, :description, :meta_title, :meta_description, :meta_keywords
    attr_accessible :translations_attributes
    accepts_nested_attributes_for :translations
  end
end
