# frozen_string_literal: true

# @component "orders/new"
class SolidusAdmin::Orders::New::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template(locals: { order: Spree::Order.new })
  end
end
