# frozen_string_literal: true

module Solidus
  # Records store specific configuration such as store name and URL.
  #
  # `Solidus::Store` provides the foundational ActiveRecord model for recording information
  # specific to your store such as its name, URL, and tax location. This model will
  # provide the foundation upon which [support for multiple stores](https://github.com/solidusio/solidus/issues/112)
  # hosted by a single Solidus implementation can be built.
  #
  class Store < Solidus::Base
    has_many :store_payment_methods, inverse_of: :store
    has_many :payment_methods, through: :store_payment_methods

    has_many :store_shipping_methods, inverse_of: :store
    has_many :shipping_methods, through: :store_shipping_methods

    has_many :orders, class_name: "Solidus::Order"

    validates :code, presence: true, uniqueness: { allow_blank: true }
    validates :name, presence: true
    validates :url, presence: true
    validates :mail_from_address, presence: true

    before_save :ensure_default_exists_and_is_unique
    before_destroy :validate_not_default

    scope :by_url, lambda { |url| where("url like ?", "%#{url}%") }

    class << self
      deprecate by_url: "Solidus::Store.by_url is DEPRECATED", deprecator: Solidus::Deprecation
    end

    def available_locales
      locales = super()
      if locales
        super().split(",").map(&:to_sym)
      else
        Solidus.i18n_available_locales
      end
    end

    def available_locales=(locales)
      locales = locales.reject(&:blank?)
      if locales.empty?
        super(nil)
      else
        super(locales.map(&:to_s).join(","))
      end
    end

    def self.current(store_key)
      Solidus::Deprecation.warn "Solidus::Store.current is DEPRECATED"
      current_store = Store.find_by(code: store_key) || Store.by_url(store_key).first if store_key
      current_store || Store.default
    end

    def self.default
      where(default: true).first || new
    end

    def default_cart_tax_location
      @default_cart_tax_location ||=
        Solidus::Tax::TaxLocation.new(country: Solidus::Country.find_by(iso: cart_tax_country_iso))
    end

    private

    def ensure_default_exists_and_is_unique
      if default
        Solidus::Store.where.not(id: id).update_all(default: false)
      elsif Solidus::Store.where(default: true).count == 0
        self.default = true
      end
    end

    def validate_not_default
      if default
        errors.add(:base, :cannot_destroy_default_store)
      end
    end
  end
end
