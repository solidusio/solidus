# frozen_string_literal: true

# @component "orders/show/address"
class SolidusAdmin::Orders::Show::Address::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    type = "ship"
    order = fake_order(type)

    render_with_template(
      locals: {
        order: order,
        type: type
      }
    )
  end

  # @param type select :type_options
  def playground(type: "ship")
    order = fake_order(type)
    render current_component.new(order: order, type: type)
  end

  private

  def fake_order(type)
    order = Spree::Order.new
    country = Spree::Country.find_or_initialize_by(iso: Spree::Config.default_country_iso)

    order.define_singleton_method(:id) { 1 }
    order.define_singleton_method(:persisted?) { true }
    order.define_singleton_method(:to_param) { id.to_s }
    order.send("build_#{type}_address", { country: country })
    order
  end

  def type_options
    current_component::VALID_TYPES
  end
end
