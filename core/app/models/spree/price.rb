module Spree
  class Price < Spree::Base
    acts_as_paranoid

    MAXIMUM_AMOUNT = BigDecimal('99_999_999.99')

    belongs_to :variant, -> { with_deleted }, class_name: 'Spree::Variant', touch: true

    after_initialize :valid_from_today!, if: -> { valid_from.blank? }

    validate :check_price
    validates :amount, allow_nil: true, numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: MAXIMUM_AMOUNT
    }

    scope :in_currency, -> (currency) { where(currency: currency) }
    scope :latest_valid_from_first, -> { order(valid_from: :desc) }
    scope :valid_before,
          -> (date) { latest_valid_from_first.where("#{Spree::Price.table_name}.valid_from <= ?", date) }
    scope :valid_before_now, -> { valid_before(Time.current) }

    # Returns a cache key for all prices in a passed in relation
    def self.cache_key
      Digest::MD5.hexdigest(valid_before_now.pluck(:id, :updated_at).flatten.join("/"))
    end

    extend DisplayMoney
    money_methods :amount, :price

    self.whitelisted_ransackable_attributes = ['amount']

    # @return [Spree::Money] this price as a Spree::Money object
    def money
      Spree::Money.new(amount || 0, { currency: currency })
    end

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

    def valid_from_today!
      self.valid_from = Time.current
    end

    def check_price
      self.currency ||= Spree::Config[:currency]
    end
  end
end
