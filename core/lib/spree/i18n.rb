require 'i18n'
require 'active_support/core_ext/array/extract_options'

module Spree
  class TranslationHelperWrapper # :nodoc:
    include ActionView::Helpers::TranslationHelper
  end

  class << self
    # Add spree namespace and delegate to Rails TranslationHelper for some nice
    # extra functionality. e.g return reasonable strings for missing translations
    def translate(key, options = {})
      options[:scope] = [:spree, *options[:scope]]
      TranslationHelperWrapper.new.translate(key, options)
    end

    alias_method :t, :translate
  end
end
