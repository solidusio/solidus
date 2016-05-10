module Spree
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

    def self.available(display_on = 'both', store: nil)
      all.select do |p|
        p.active &&
          (p.display_on == display_on.to_s || p.display_on.blank?) &&
          (store.nil? || store.payment_methods.empty? || store.payment_methods.include?(p))
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
