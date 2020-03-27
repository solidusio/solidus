# frozen_string_literal: true

module Spree
  class Price < Spree::Base
    include Spree::SoftDeletable

    MAXIMUM_AMOUNT = BigDecimal('99_999_999.99')

    belongs_to :variant, -> { with_discarded }, class_name: 'Spree::Variant', touch: true, optional: true
    belongs_to :country, class_name: "Spree::Country", foreign_key: "country_iso", primary_key: "iso", optional: true

    delegate :product, to: :variant
    delegate :tax_rates, to: :variant

    validate :check_price
    validates :amount, allow_nil: true, numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: MAXIMUM_AMOUNT
    }
    validates :currency, inclusion: { in: ::Money::Currency.all.map(&:iso_code), message: :invalid_code }
    validates :country, presence: true, unless: -> { for_any_country? }

    scope :currently_valid, -> { order(Arel.sql("country_iso IS NULL")).order(updated_at: :DESC, id: :DESC) }
    scope :for_master, -> { joins(:variant).where(spree_variants: { is_master: true }) }
    scope :for_variant, -> { joins(:variant).where(spree_variants: { is_master: false }) }
    scope :for_any_country, -> { where(country: nil) }
    scope :with_default_attributes, -> { where(Spree::Config.default_pricing_options.desired_attributes) }

    extend DisplayMoney
    money_methods :amount, :price
    alias_method :money, :display_amount

    self.whitelisted_ransackable_attributes = %w(amount variant_id currency country_iso)

    # An alias for #amount
    def price
      amount
    end

    # Sets this price's amount to a new value, parsing it if the new value is
    # a string.
    #
    # @param price [String, #to_d] a new amount
    def price=(price)
      self[:amount] = Spree::LocalizedNumber.parse(price)
    end

    def net_amount
      amount / (1 + sum_of_vat_amounts)
    end

    def for_any_country?
      country_iso.nil?
    end

    def display_country
      if country_iso
        "#{country_iso} (#{country.name})"
      else
        I18n.t(:any_country, scope: [:spree, :admin, :prices])
      end
    end

    def country_iso=(country_iso)
      self[:country_iso] = country_iso.presence
    end

    private

    def sum_of_vat_amounts
      return 0 unless variant.tax_category
      tax_rates.included_in_price.for_country(country).sum(:amount)
    end

    def check_price
      self.currency ||= Spree::Config[:currency]
    end

    def pricing_options
      Spree::Config.pricing_options_class.from_price(self)
    end
  end
end
