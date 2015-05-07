# encoding: utf-8

require 'money'

module Spree
  # Spree::Money is a relatively thin wrapper around Monetize which handles
  # formatting via Spree::Config.
  class Money
    attr_reader :money

    delegate :cents, to: :money

    # @param amount [#to_s] the value of the money object
    # @param options [Hash] the options for creating the money object
    # @option options [String] currency the currency for the money object
    # @option options [Boolean] with_currency when true, show the currency
    # @option options [Boolean] no_cents when true, round to the closest dollar
    # @option options [String] decimal_mark the mark for delimiting the
    #   decimals
    # @option options [String, false, nil] thousands_separator the character to
    #   delimit powers of 1000, if one is desired, otherwise false or nil
    # @option options [Boolean] sign_before_symbol when true the sign of the
    #   value comes before the currency symbol
    # @option options [:before, :after] symbol_position the position of the
    #   currency symbol
    def initialize(amount, options={})
      @money = Monetize.parse([amount, (options[:currency] || Spree::Config[:currency])].join)
      @options = {}
      @options[:with_currency] = Spree::Config[:display_currency]
      @options[:symbol_position] = Spree::Config[:currency_symbol_position].to_sym
      @options[:no_cents] = Spree::Config[:hide_cents]
      @options[:decimal_mark] = Spree::Config[:currency_decimal_mark]
      @options[:thousands_separator] = Spree::Config[:currency_thousands_separator]
      @options[:sign_before_symbol] = Spree::Config[:currency_sign_before_symbol]
      @options.merge!(options)
      # Must be a symbol because the Money gem doesn't do the conversion
      @options[:symbol_position] = @options[:symbol_position].to_sym
    end

    # @return [String] the value of this money object formatted according to
    #   its options
    def to_s
      @money.format(@options)
    end

    # @note If you pass in options, ensure you pass in the html: true as well.
    # @param options [Hash] additional formatting options
    # @return [String] the value of this money object formatted according to
    #   its options and any additional options, by default as html.
    def to_html(options = { html: true })
      output = @money.format(@options.merge(options))
      if options[:html]
        # 1) prevent blank, breaking spaces
        # 2) prevent escaping of HTML character entities
        output = output.sub(" ", "&nbsp;").html_safe
      end
      output
    end

    # (see #to_s)
    def as_json(*)
      to_s
    end

    # Delegates comparison to the internal ruby money instance.
    #
    # @see http://www.rubydoc.info/gems/money/Money/Arithmetic#%3D%3D-instance_method
    def ==(obj)
      @money == obj.money
    end
  end
end
