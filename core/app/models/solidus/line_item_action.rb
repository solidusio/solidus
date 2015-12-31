module Solidus
  class LineItemAction < Solidus::Base
    belongs_to :line_item
    belongs_to :action, class_name: "Solidus::PromotionAction"
  end
end
