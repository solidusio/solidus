module Spree
  OptionType.class_eval do
    translates :name, :presentation
    attr_accessible :translations_attributes
    accepts_nested_attributes_for :translations
  end
end
