# frozen_string_literal: true

module SolidusPromotions
  # Normalizes coupon codes before saving or looking up promotions.
  #
  # By default, this class strips whitespace and downcases the code
  # to ensure case-insensitive behavior. You can override this class
  # or provide a custom normalizer class to change behavior (e.g.,
  # case-sensitive codes) via:
  #
  #   SolidusPromotions.configure do |config|
  #     config.coupon_code_normalizer_class = YourCustomNormalizer
  #   end
  #
  # @example Default usage
  #   CouponCodeNormalizer.call(" SAVE20 ") # => "save20"
  #
  # @example Custom case-sensitive usage
  #   class CaseSensitiveNormalizer
  #     def self.call(value)
  #       value&.strip
  #     end
  #   end
  #
  #   SolidusPromotions.configure do |config|
  #     config.coupon_code_normalizer_class = CaseSensitiveNormalizer
  #   end
  class CouponCodeNormalizer
    # Normalizes the given coupon code.
    #
    # @param value [String, nil] the coupon code to normalize
    # @return [String, nil] the normalized coupon code
    def self.call(value)
      value&.strip&.downcase
    end
  end
end
