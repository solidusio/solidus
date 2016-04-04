module Spree
  module DefaultPrice
    extend ActiveSupport::Concern

    included do
      has_one :default_price,
        -> { with_deleted.where(currency: Spree::Config[:currency], is_default: true) },
        class_name: 'Spree::Price',
        inverse_of: :variant,
        dependent: :destroy,
        autosave: true

      after_save :save_default_price
    end

    def find_or_build_default_price
      default_price || build_default_price
    end

    delegate :display_price, :display_amount,
      :price, :price=, :currency, :currency=,
      to: :find_or_build_default_price

    def has_default_price?
      !default_price.nil?
    end

    private

    def default_price_changed?
      default_price && (default_price.changed? || default_price.new_record?)
    end

    def save_default_price
      default_price.save if default_price_changed?
    end
  end
end
