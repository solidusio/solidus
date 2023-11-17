# frozen_string_literal: true

# @component "orders/show/summary"
class SolidusAdmin::Orders::Show::Summary::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    order = fake_order(item_total: 340, additional_tax_total: 10, shipment_total: 20, promo_total: 10, adjustment_total: 20)
    render_with_template(locals: { order: order })
  end

  # @param item_total [Float]
  # @param additional_tax_total [Float]
  # @param shipment_total [Float]
  # @param promo_total [Float]
  # @param adjustment_total [Float]
  def playground(item_total: 100, additional_tax_total: 10, shipment_total: 5, promo_total: 0, adjustment_total: 0)
    fake_order = fake_order(
      item_total: item_total,
      additional_tax_total: additional_tax_total,
      shipment_total: shipment_total,
      promo_total: promo_total,
      adjustment_total: adjustment_total
    )

    render current_component.new(order: fake_order)
  end

  private

  def fake_order(item_total:, additional_tax_total:, shipment_total:, promo_total:, adjustment_total:)
    order = Spree::Order.new

    order.define_singleton_method(:item_total) { item_total }
    order.define_singleton_method(:additional_tax_total) { additional_tax_total }
    order.define_singleton_method(:shipment_total) { shipment_total }
    order.define_singleton_method(:promo_total) { promo_total }
    order.define_singleton_method(:adjustment_total) { adjustment_total }
    order.define_singleton_method(:total) {
      item_total.to_f + additional_tax_total.to_f + shipment_total.to_f - promo_total.to_f - adjustment_total.to_f
    }

    order
  end
end
