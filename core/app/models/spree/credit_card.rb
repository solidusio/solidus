module Spree
  class CreditCard < Spree::Base
    belongs_to :payment_method
    belongs_to :user, class_name: Spree.user_class, foreign_key: 'user_id'
    belongs_to :address
    has_many :payments, as: :source

    before_save :set_last_digits

    after_save :ensure_one_default

    accepts_nested_attributes_for :address

    attr_reader :number
    attr_accessor :encrypted_data,
                    :imported,
                    :verification_value

    validates :month, :year, numericality: { only_integer: true }, if: :require_card_numbers?, on: :create
    validates :number, presence: true, if: :require_card_numbers?, on: :create, unless: :imported
    validates :name, presence: true, if: :require_card_numbers?, on: :create
    validates :verification_value, presence: true, if: :require_card_numbers?, on: :create, unless: :imported

    scope :with_payment_profile, -> { where('gateway_customer_profile_id IS NOT NULL') }
    scope :default, -> { where(default: true) }

    # needed for some of the ActiveMerchant gateways (eg. SagePay)
    alias_attribute :brand, :cc_type

    CARD_TYPES = {
      visa: /^4[0-9]{12}(?:[0-9]{3})?$/,
      master: /(^5[1-5][0-9]{14}$)|(^6759[0-9]{2}([0-9]{10})$)|(^6759[0-9]{2}([0-9]{12})$)|(^6759[0-9]{2}([0-9]{13})$)/,
      diners_club: /^3(?:0[0-5]|[68][0-9])[0-9]{11}$/,
      american_express: /^3[47][0-9]{13}$/,
      discover: /^6(?:011|5[0-9]{2})[0-9]{12}$/,
      jcb: /^(?:2131|1800|35\d{3})\d{11}$/
    }

    def address_attributes=(attributes)
      self.address = Address.immutable_merge(address, attributes)
    end

    # Sets the expiry date on this credit card.
    #
    # @param expiry [String] the desired new expiry date in one of the
    #   following formats: "mm/yy", "mm / yyyy", "mmyy", "mmyyyy"
    def expiry=(expiry)
      return unless expiry.present?

      self[:month], self[:year] =
        if expiry =~ /\d{2}\s?\/\s?\d{2,4}/ # will match mm/yy and mm / yyyy
          expiry.delete(' ').split('/')
        elsif match = expiry.match(/(\d{2})(\d{2,4})/) # will match mmyy and mmyyyy
          [match[1], match[2]]
        end
      if self[:year]
        self[:year] = "20" + self[:year] if self[:year].length == 2
        self[:year] = self[:year].to_i
      end
      self[:month] = self[:month].to_i if self[:month]
    end

    # Sets the credit card number, removing any non-numeric characters.
    #
    # @param num [String] the desired credit card number
    def number=(num)
      @number =
        if num.is_a?(String)
          num.gsub(/[^0-9]/, '')
        end
    end

    # Sets the credit card type, converting it to the preferred internal
    # representation from jquery.payment's representation when appropriate.
    #
    # @param type [String] the desired credit card type
    def cc_type=(type)
      # cc_type is set by jquery.payment, which helpfully provides different
      # types from Active Merchant. Converting them is necessary.
      self[:cc_type] = case type
                       when 'mastercard', 'maestro' then 'master'
                       when 'amex' then 'american_express'
                       when 'dinersclub' then 'diners_club'
                       when '' then try_type_from_number
      else type
      end
    end

    # Sets the last digits field based on the assigned credit card number.
    def set_last_digits
      verification_value.to_s.gsub!(/\s/, '')
      self.last_digits ||= number.to_s.length <= 4 ? number : number.to_s.slice(-4..-1)
    end

    # @return [String] the credit card type if it can be determined from the
    #   number, otherwise the empty string
    def try_type_from_number
      numbers = number.delete(' ') if number
      CARD_TYPES.find{ |type, pattern| return type.to_s if numbers =~ pattern }.to_s
    end

    # @return [Boolean] true when a verification value is present
    def verification_value?
      verification_value.present?
    end

    # @return [String] the card number, with all but last 4 numbers replace
    #   with "X", as in "XXXX-XXXX-XXXX-4338"
    def display_number
      "XXXX-XXXX-XXXX-#{last_digits}"
    end

    # @return [Array<String>] the actions available on this credit card
    def actions
      %w{capture void credit}
    end

    # @param payment [Spree::Payment] the payment we want to know if can be captured
    # @return [Boolean] true when the payment is in the pending or checkout states
    def can_capture?(payment)
      payment.pending? || payment.checkout?
    end

    # @param payment [Spree::Payment] the payment we want to know if can be voided
    # @return [Boolean] true when the payment is not failed or voided
    def can_void?(payment)
      !payment.failed? && !payment.void?
    end

    # Indicates whether its possible to credit the payment.  Note that most
    # gateways require that the payment be settled first which generally
    # happens within 12-24 hours of the transaction.
    #
    # @param payment [Spree::Payment] the payment we want to know if can be credited
    # @return [Boolean] true when the payment is completed and can be credited
    def can_credit?(payment)
      payment.completed? && payment.credit_allowed > 0
    end

    # @return [Boolean] true when there is a gateway customer or payment
    #   profile id present
    def has_payment_profile?
      gateway_customer_profile_id.present? || gateway_payment_profile_id.present?
    end

    # @note ActiveMerchant needs first_name/last_name because we pass it a
    #   Spree::CreditCard and it calls those methods on it.
    # @todo We should probably be calling #to_active_merchant before passing
    #   the object to ActiveMerchant.
    # @return [String] the first name on this credit card
    def first_name
      name.to_s.split(/[[:space:]]/, 2)[0]
    end

    # @note ActiveMerchant needs first_name/last_name because we pass it a
    #   Spree::CreditCard and it calls those methods on it.
    # @todo We should probably be calling #to_active_merchant before passing
    #   the object to ActiveMerchant.
    # @return [String] the last name on this credit card
    def last_name
      name.to_s.split(/[[:space:]]/, 2)[1]
    end

    # @return [ActiveMerchant::Billing::CreditCard] an ActiveMerchant credit
    #   card that represents this credit card
    def to_active_merchant
      ActiveMerchant::Billing::CreditCard.new(
        number: number,
        month: month,
        year: year,
        verification_value: verification_value,
        first_name: first_name,
        last_name: last_name
      )
    end

    private

    def require_card_numbers?
      !encrypted_data.present? && !has_payment_profile?
    end

    def ensure_one_default
      if user_id && default
        CreditCard.where(default: true).where.not(id: id).where(user_id: user_id).each do |ucc|
          ucc.update_columns(default: false, updated_at: Time.current)
        end
      end
    end
  end
end
