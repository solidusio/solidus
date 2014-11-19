module Spree
  class Price < Spree::Base
    acts_as_paranoid
    belongs_to :variant, class_name: 'Spree::Variant', inverse_of: :prices, touch: true

    validate :check_price
    validates :amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
    validate :validate_amount_maximum
    after_save :set_default_price

    extend DisplayMoney
    money_methods :amount, :price

    def money
      Spree::Money.new(amount || 0, { currency: currency })
    end

    def price
      amount
    end

    def price=(price)
      self[:amount] = Spree::LocalizedNumber.parse(price)
    end

    # Remove variant default_scope `deleted_at: nil`
    def variant
      Spree::Variant.unscoped { super }
    end

    private

    def check_price
      self.currency ||= Spree::Config[:currency]
    end

    def maximum_amount
      BigDecimal '999999.99'
    end

    def validate_amount_maximum
      if amount && amount > maximum_amount
        errors.add :amount, I18n.t('errors.messages.less_than_or_equal_to', count: maximum_amount)
      end
    end

    def set_default_price
      if is_default?
        other_default_prices = variant.prices.where(currency: self.currency, is_default: true).where.not(id: self.id)
        other_default_prices.each { |p| p.update_attributes!(is_default: false) }
      end
    end
  end
end
