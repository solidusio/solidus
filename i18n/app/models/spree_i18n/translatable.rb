module SpreeI18n
  module Translatable
    extend ActiveSupport::Concern
    included do
      accepts_nested_attributes_for :translations
    end
  end
end
