# frozen_string_literal: true

module Solidus
  class LineItemAction < Solidus::Base
    belongs_to :line_item, optional: true
    belongs_to :action, class_name: "Solidus::PromotionAction", optional: true
  end
end
