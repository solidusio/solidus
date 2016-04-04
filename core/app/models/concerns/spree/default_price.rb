module Spree
  # Adds a `#default_price` `has_one` relation to the including model
  #
  # The default price is the price displayed in the admin as the main price for a product,
  # for example on the Spree::Product#index page.
  # It also defines getters for price-related properties on the variant that will return the
  # properties of the default price.
  # If you change the default price on a variant using `Spree::Variant#price=`, a new price object
  # will be created and the old one soft-deleted. The deletion can not be avoided:
  #
  # ActiveRecord destroys stale `has_one` records, as one might expect from a 1:1 relation:
  # https://github.com/rails/rails/blob/4-2-stable/activerecord/lib/active_record/associations/has_one_association.rb#L35
  # https://github.com/rails/rails/blob/4-2-stable/activerecord/lib/active_record/associations/has_one_association.rb#L76-L91
  # There is no way to prevent that, unfortunately, so we have to rely on `acts_as_paranoid`
  # to keep historical records.
  #
  # We have to use an ActiveRecord association though, because the backend forms need it for Ransacks
  # searching and sorting functionality.
  #
  module DefaultPrice
    extend ActiveSupport::Concern

    included do
      # Price to be used in the backend
      # @return [Spree::Price] The backend price for the including object
      has_one :default_price,
        -> { Spree::Price.default_prices },
        class_name: 'Spree::Price',
        inverse_of: name.demodulize.underscore.to_sym,
        dependent: :destroy,
        autosave: true
    end
    # Delegate getters for price-related variant properties to the relation defined above.
    delegate :display_price, :display_amount, :price, :currency, to: :default_price, allow_nil: true

    # Build a new price object and soft-delete the current one so we keep a history of prices.
    delegate :price=, to: :build_default_price

    # @return [Boolean] Does the including object (ie: Variant) have a default price already?
    def has_default_price?
      default_price.present?
    end
  end
end
