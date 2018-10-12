# frozen_string_literal: true

require 'i18n'
require 'active_support/core_ext/array/extract_options'
require 'action_view'

module Spree
  def self.i18n_available_locales
    I18n.available_locales.select do |locale|
      I18n.t('spree.i18n.this_file_language', locale: locale, fallback: false, default: nil)
    end
  end

  class TranslationHelperWrapper # :nodoc:
    include ActionView::Helpers::TranslationHelper
  end

  # This value is used as a count for the pluralization helpers related to I18n
  # ex: Spree::Order.model_name.human(count: Spree::I18N_GENERIC_PLURAL)
  # Related to Solidus issue #1164, this is needed to avoid problems with
  # some pluralization calculators
  I18N_GENERIC_PLURAL = 2.1

  class << self
    # Add spree namespace and delegate to Rails TranslationHelper for some nice
    # extra functionality. e.g return reasonable strings for missing translations

    def translate(key, options = {})
      Spree::Deprecation.warn <<-WARN.squish
        Spree.t & Spree.translate have been deprecated.
        Instead use I18n.t('spree.your_translation_key')
      WARN
      options[:scope] = [:spree, *options[:scope]]
      TranslationHelperWrapper.new.translate(key, options)
    end

    alias_method :t, :translate
  end
end
