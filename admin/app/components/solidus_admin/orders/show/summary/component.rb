# frozen_string_literal: true

class SolidusAdmin::Orders::Show::Summary::Component < SolidusAdmin::BaseComponent
  def initialize(order:)
    @order = order
  end
end
