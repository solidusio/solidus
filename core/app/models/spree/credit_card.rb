# frozen_string_literal: true

module Spree
  # The default `source` of a `Spree::Payment`.
  #
  class CreditCard < Spree::PaymentSource
    belongs_to :user, class_name: Spree::UserClassHandle.new, optional: true
    belongs_to :address, optional: true

    before_save :set_last_digits

    accepts_nested_attributes_for :address

    attr_reader :number, :verification_value
    attr_accessor :encrypted_data

    validates :month, :year, numericality: {only_integer: true}, if: :require_card_numbers?, on: :create
    validates :number, presence: true, if: :require_card_numbers?, on: :create, unless: :imported
    validates :name, presence: true, if: :require_card_numbers?, on: :create
    validates :verification_value, presence: true, if: :require_card_numbers?, on: :create, unless: :imported

    scope :with_payment_profile, -> { where.not(gateway_customer_profile_id: nil) }

    # Taken from ActiveMerchant
    # https://github.com/activemerchant/active_merchant/blob/2f2acd4696e8de76057b5ed670b9aa022abc1187/lib/active_merchant/billing/credit_card_methods.rb#L5
    CARD_TYPES = {
      "visa" => /^4\d{12}(\d{3})?(\d{3})?$/,
      "master" => /^(5[1-5]\d{4}|677189|222[1-9]\d{2}|22[3-9]\d{3}|2[3-6]\d{4}|27[01]\d{3}|2720\d{2})\d{10}$/,
      "discover" => /^(6011|65\d{2}|64[4-9]\d)\d{12}|(62\d{14})$/,
      "american_express" => /^3[47]\d{13}$/,
      "diners_club" => /^3(0[0-5]|[68]\d)\d{11}$/,
      "jcb" => /^35(28|29|[3-8]\d)\d{12}$/,
      "switch" => /^6759\d{12}(\d{2,3})?$/,
      "solo" => /^6767\d{12}(\d{2,3})?$/,
      "dankort" => /^5019\d{12}$/,
      "maestro" => /^(5[06-8]|6\d)\d{10,17}$/,
      "forbrugsforeningen" => /^600722\d{10}$/,
      "laser" => /^(6304|6706|6709|6771(?!89))\d{8}(\d{4}|\d{6,7})?$/
    }.freeze

    def address_attributes=(attributes)
      self.address = Spree::Address.immutable_merge(address, attributes)
    end

    # Sets the expiry date on this credit card.
    #
    # @param expiry [String] the desired new expiry date in one of the
    #   following formats: "mm/yy", "mm / yyyy", "mmyy", "mmyyyy"
    def expiry=(expiry)
      return unless expiry.present?

      self[:month], self[:year] =
        if /\d{2}\s?\/\s?\d{2,4}/.match?(expiry) # will match mm/yy and mm / yyyy
          expiry.delete(" ").split("/")
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
          num.gsub(/[^0-9]/, "")
        end
    end

    def verification_value=(value)
      @verification_value = value.to_s.gsub(/\s/, "")
    end

    # Sets the credit card type, converting it to the preferred internal
    # representation from jquery.payment's representation when appropriate.
    #
    # @param type [String] the desired credit card type
    def cc_type=(type)
      # cc_type is set by jquery.payment, which helpfully provides different
      # types from Active Merchant. Converting them is necessary.
      self[:cc_type] = case type
      when "mastercard", "maestro" then "master"
      when "amex" then "american_express"
      when "dinersclub" then "diners_club"
      when "" then try_type_from_number
      else type
      end
    end

    # needed for some of the ActiveMerchant gateways (eg. SagePay)
    alias_attribute :brand, :cc_type

    # Rails 7.1+ won't use the custom setter with alias_attribute
    alias_method :brand=, :cc_type=

    # Sets the last digits field based on the assigned credit card number.
    def set_last_digits
      self.last_digits ||= (number.to_s.length <= 4) ? number : number.to_s.slice(-4..)
    end

    # @return [String] the credit card type if it can be determined from the
    #   number, otherwise the empty string
    def try_type_from_number
      CARD_TYPES.each do |type, pattern|
        return type if number&.match?(pattern)
      end
      ""
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

    def reusable?
      has_payment_profile?
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
      Spree::Address::Name.new(name).first_name
    end

    # @note ActiveMerchant needs first_name/last_name because we pass it a
    #   Spree::CreditCard and it calls those methods on it.
    # @todo We should probably be calling #to_active_merchant before passing
    #   the object to ActiveMerchant.
    # @return [String] the last name on this credit card
    def last_name
      Spree::Address::Name.new(name).last_name
    end

    # @return [ActiveMerchant::Billing::CreditCard] an ActiveMerchant credit
    #   card that represents this credit card
    def to_active_merchant
      ActiveMerchant::Billing::CreditCard.new(
        number:,
        month:,
        year:,
        verification_value:,
        first_name:,
        last_name:
      )
    end

    private

    def require_card_numbers?
      !encrypted_data.present? && !has_payment_profile?
    end
  end
end
