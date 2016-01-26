# encoding: utf-8

require 'money'

module Spree
  # Spree::Money is a relatively thin wrapper around Monetize which handles
  # formatting via Spree::Config.
  class Money
    class <<self
      attr_accessor :default_formatting_rules
    end
    self.default_formatting_rules = {
      # Ruby money currently has this as false, which is wrong for the vast
      # majority of locales.
      sign_before_symbol: true
    }

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
    def initialize(amount, options = {})
      @money = Monetize.parse([amount, (options[:currency] || Spree::Config[:currency])].join)
      @options = Spree::Money.default_formatting_rules.merge(options)
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
