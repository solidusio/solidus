module Spree
  # An abstract class which is implemented most commonly as a `Spree::Gateway`.
  #
  class PaymentMethod < Spree::Base
    acts_as_paranoid
    acts_as_list
    DISPLAY = [:both, :front_end, :back_end]

    validates :name, presence: true

    has_many :payments, class_name: "Spree::Payment", inverse_of: :payment_method
    has_many :credit_cards, class_name: "Spree::CreditCard"
    has_many :store_payment_methods, inverse_of: :payment_method
    has_many :stores, through: :store_payment_methods

    scope :ordered_by_position, -> { order(:position) }
    scope :active, -> { where(active: true) }
    scope :available_to_users, -> { where(available_to_users: true) }
    scope :available_to_admin, -> { where(available_to_admin: true) }
    scope :available_to_store, -> (store) { (store.present? && store.payment_methods.empty?) ? self : store.payment_methods }

    include Spree::Preferences::StaticallyConfigurable

    def self.providers
      Rails.application.config.spree.payment_methods
    end

    def provider_class
      raise ::NotImplementedError, "You must implement provider_class method for #{self.class}."
    end

    # The class that will process payments for this payment type, used for @payment.source
    # e.g. CreditCard in the case of a the Gateway payment type
    # nil means the payment method doesn't require a source e.g. check
    def payment_source_class
      raise ::NotImplementedError, "You must implement payment_source_class method for #{self.class}."
    end

    # @deprecated Use {#available_to_users=} and {#available_to_admin=} instead
    def display_on=(value)
      Spree::Deprecation.warn "Spree::PaymentMethod#display_on= is deprecated."\
        "Please use #available_to_users= and #available_to_admin= instead."
      self.available_to_users = value.blank? || value == 'front_end'
      self.available_to_admin = value.blank? || value == 'back_end'
    end

    # @deprecated Use {#available_to_users} and {#available_to_admin} instead
    def display_on
      Spree::Deprecation.warn "Spree::PaymentMethod#display_on is deprecated."\
        "Please use #available_to_users and #available_to_admin instead."
      if available_to_users? && available_to_admin?
        ''
      elsif available_to_users?
        'front_end'
      elsif available_to_admin?
        'back_end'
      else
        'none'
      end
    end

    def self.available(display_on=nil, store: nil)
      Spree::Deprecation.warn "Spree::PaymentMethod.available is deprecated."\
        "Please use .active, .available_to_users, and .available_to_admin scopes instead."\
        "For payment methods associated with a specific store, use Spree::PaymentMethod.available_to_store(your_store)"\
        " as the base applying any further filtering"

      display_on = display_on.to_s

      available_payment_methods =
        case display_on
        when 'front_end'
          active.available_to_users
        when 'back_end'
          active.available_to_admin
        else
          active.available_to_users.available_to_admin
        end
      available_payment_methods.select do |p|
        store.nil? || store.payment_methods.empty? || store.payment_methods.include?(p)
      end
    end

    def self.active?
      where(type: to_s, active: true).count > 0
    end

    def method_type
      type.demodulize.downcase
    end

    def self.find_with_destroyed(*args)
      unscoped { find(*args) }
    end

    def payment_profiles_supported?
      false
    end

    def source_required?
      true
    end

    # Custom gateways should redefine this method. See Gateway implementation
    # as an example
    def reusable_sources(_order)
      []
    end

    def auto_capture?
      auto_capture.nil? ? Spree::Config[:auto_capture] : auto_capture
    end

    def supports?(_source)
      true
    end

    def cancel(_response)
      raise ::NotImplementedError, 'You must implement cancel method for this payment method.'
    end

    def store_credit?
      is_a? Spree::PaymentMethod::StoreCredit
    end
  end
end
