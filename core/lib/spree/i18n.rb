# frozen_string_literal: true

require "i18n"

module Spree
  def self.i18n_available_locales
    I18n.available_locales.select do |locale|
      I18n.t("spree.i18n.this_file_language", locale:, fallback: false, default: nil)
    end
  end

  # This value is used as a count for the pluralization helpers related to I18n
  # ex: Spree::Order.model_name.human(count: Spree::I18N_GENERIC_PLURAL)
  # Related to Solidus issue #1164, this is needed to avoid problems with
  # some pluralization calculators
  I18N_GENERIC_PLURAL = 2.1
end
