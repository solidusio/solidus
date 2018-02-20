# frozen_string_literal: true

module Spree
  class LocalizedNumber
    # Given a string, strips all non-price-like characters from it,
    # taking into account locale settings. Returns the input given anything
    # else.
    #
    # @param number [String, anything] the number to be parsed or anything else
    # @return [BigDecimal, anything] the number parsed from the string passed
    #   in, or whatever you passed in
    def self.parse(number)
      return number unless number.is_a?(String)

      # I18n.t('number.currency.format.delimiter') could be useful here, but is
      # unnecessary as it is stripped by the non_number_characters gsub.
      separator = I18n.t(:'number.currency.format.separator')
      non_number_characters = /[^0-9\-#{separator}]/

      # strip everything else first
      number = number.gsub(non_number_characters, '')

      # then replace the locale-specific decimal separator with the standard separator if necessary
      number = number.gsub(separator, '.') unless separator == '.'

      # Handle empty string for ruby 2.4 compatibility
      BigDecimal(number.presence || 0)
    end
  end
end
