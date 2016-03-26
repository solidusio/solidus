module Spree
  class Price < Spree::Base
    # Because Rails destroys stale has_one records (see the Spree::DefaultPrice module for further
    # information), we need `acts_as_paranoid` to keep historical records for us.
    #
    # The price relations on `Spree::Variant` are all scoped `with_deleted`, as we can not rely
    # on the `deleted_at` accurately reflecting whether we have the right record. We rather use
    # `valid_from` to figure out which price is the correct one to use.
    acts_as_paranoid

    MAXIMUM_AMOUNT = BigDecimal('99_999_999.99')

    belongs_to :variant, -> { with_deleted }, class_name: 'Spree::Variant', touch: true

    before_save :valid_from_today!, if: -> { valid_from.blank? }
    before_save :set_default_currency, if: -> { currency.blank? }

    validates :amount, allow_nil: true, numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: MAXIMUM_AMOUNT
    }

    scope :in_currency, -> (currency) { where(currency: currency) }
    scope :latest_valid_from_first, -> { order(valid_from: :desc) }
    scope :valid_before,
          -> (date) { latest_valid_from_first.where("#{Spree::Price.table_name}.valid_from <= ?", date) }
    scope :valid_before_now, -> { valid_before(Time.current) }
    scope :with_default_currency, -> { where(currency: Spree::Config.currency) }

    # The scope to be passed into a `default_price` association for an object that needs a default price
    # @return [ActiveRecord::Relation] A scope where the first object is the current default price
    scope :default_prices, -> { with_deleted.with_default_currency.valid_before_now }

    # Returns a fixed-length cache key for all prices in a passed in relation
    #
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

    def set_default_currency
      self.currency = Spree::Config.currency
    end
  end
end
