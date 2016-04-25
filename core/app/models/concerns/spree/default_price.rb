module Spree
  module DefaultPrice
    extend ActiveSupport::Concern

    included do
      has_one :default_price,
        -> { with_deleted.currently_valid.with_default_attributes },
        class_name: 'Spree::Price',
        inverse_of: :variant,
        dependent: :destroy,
        autosave: true
    end

    def find_or_build_default_price
      default_price || build_default_price(Spree::Config.default_pricing_options.desired_attributes)
    end

    delegate :display_price, :display_amount, :price, :currency, to: :find_or_build_default_price
    delegate :price=, :currency=, to: :find_or_build_default_price
    deprecate :currency=, :currency, deprecator: Spree::Deprecation

    def has_default_price?
      !default_price.nil?
    end
  end
end
