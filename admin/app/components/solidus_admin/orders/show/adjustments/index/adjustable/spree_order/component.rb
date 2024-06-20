# frozen_string_literal: true

class SolidusAdmin::Orders::Show::Adjustments::Index::Adjustable::SpreeOrder::Component < SolidusAdmin::Orders::Show::Adjustments::Index::Adjustable::Component
  def caption
    "#{Spree::Order.model_name.human} ##{adjustable.number}"
  end

  def detail
    adjustable.display_total
  end
end
