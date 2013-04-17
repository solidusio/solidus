module Spree
  Taxonomy.class_eval do
    translates :name
    attr_accessible :translations_attributes
    accepts_nested_attributes_for :translations
  end
end
