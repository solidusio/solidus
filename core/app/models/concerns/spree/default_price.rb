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
    end

    def find_or_build_default_price
      default_price || build_default_price
    end

    delegate :display_price, :display_amount, :price, :currency, to: :find_or_build_default_price
    delegate :price=, :currency=, to: :find_or_build_default_price

    def has_default_price?
      !default_price.nil?
    end
  end
end
