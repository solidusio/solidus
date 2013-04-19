module SpreeI18n
  module Translatable
    extend ActiveSupport::Concern
    included do
      attr_accessible :translations_attributes
      accepts_nested_attributes_for :translations
    end
  end
end
