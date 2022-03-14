# frozen_string_literal: true

module Spree
  class LineItemDiscount < Spree::Base
    belongs_to :line_item, inverse_of: :discounts
    belongs_to :promotion_action, -> { with_discarded }, inverse_of: :line_item_discounts
  end
end
