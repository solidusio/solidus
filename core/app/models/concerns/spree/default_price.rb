module Spree
  module DefaultPrice
    extend ActiveSupport::Concern

    included do
      has_one :default_price,
        -> { with_deleted.where(currency: Spree::Config[:currency]).valid_before_now },
        class_name: 'Spree::Price',
        inverse_of: :variant,
        dependent: :destroy,
        autosave: true
    end
    delegate :display_price, :display_amount, :price, :currency, to: :default_price, allow_nil: true

    delegate :price=, to: :build_default_price

    def has_default_price?
      !default_price.nil?
    end
  end
end
