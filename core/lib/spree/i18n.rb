require 'i18n'
require 'active_support/core_ext/array/extract_options'

module Spree
  class TranslationHelperWrapper # :nodoc:
    include ActionView::Helpers::TranslationHelper
  end

  class << self
    # This value is used as a count for the pluralization helpers related to I18n
    # ex: Spree::Order.model_name.human(count: Spree::I18N_GENERIC_PLURAL)
    # Related to Solidus issue #1164, this is needed to avoid problems with
    # some pluralization calculators

    Spree::I18N_GENERIC_PLURAL = 2.1
    # Add spree namespace and delegate to Rails TranslationHelper for some nice
    # extra functionality. e.g return reasonable strings for missing translations

    def translate(key, options = {})
      options[:scope] = [:spree, *options[:scope]]
      TranslationHelperWrapper.new.translate(key, options)
    end

    alias_method :t, :translate
  end
end
