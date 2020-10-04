# frozen_string_literal: true

module Spree
  class LineItemAction < Spree::Base
    belongs_to :line_item, optional: true
    belongs_to :action, class_name: "Spree::PromotionAction", optional: true
  end
end
