# frozen_string_literal: true

class SolidusAdmin::Orders::Show::CustomerSearch::Component < SolidusAdmin::BaseComponent
  def initialize(order:)
    @order = order
  end
end
