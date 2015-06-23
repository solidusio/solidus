module Spree
  class LineItemAction < ActiveRecord::Base
    belongs_to :line_item
    belongs_to :action, class_name: "Spree::PromotionAction"
  end
end
