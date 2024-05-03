# frozen_string_literal: true

module Spree
  class NullPromotionAdvertiser
    def self.for_product(_product)
      []
    end
  end
end
