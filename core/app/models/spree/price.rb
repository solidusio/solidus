module Spree
  class Price < Spree::Base
    acts_as_paranoid

    MAXIMUM_AMOUNT = BigDecimal('99_999_999.99')

    belongs_to :variant, -> { with_deleted }, class_name: 'Spree::Variant', touch: true
    has_one :product, class_name: 'Spree::Product', through: :variant

    validate :check_price
    validates :amount, allow_nil: true, numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: MAXIMUM_AMOUNT
    }

    validates :currency, inclusion: { in: ::Money::Currency.all.map(&:iso_code), message: :invalid_code }

    # This scope can and will be enhanced in the future
    scope :currently_valid, -> { order(updated_at: :desc) }
    scope :with_default_attributes, -> { where(Spree::Config.default_pricing_options.desired_attributes) }

    extend DisplayMoney
    money_methods :amount, :price
    alias_method :money, :display_amount

    self.whitelisted_ransackable_attributes = %w( amount variant_id currency )

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

    private

    def check_price
      self.currency ||= Spree::Config[:currency]
    end

    def pricing_options
      Spree::Config.pricing_options_class.from_price(self)
    end
  end
end
