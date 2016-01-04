require 'spec_helper'

describe Spree::Order do
  let(:order) { create(:order_with_line_items) }
  let(:quadcopter) { create(:shipping_method, name: "Quads'r'us", code: "QUADSRUS", cost: 200) }

  it "preserves selected shipping method when update_cart and next! called" do
    #choose more expensive quadcopter shipping method
    original_shipment = order.shipments.first
    quadcopter_rate = original_shipment.add_shipping_method(quadcopter)
    original_shipment.selected_shipping_rate_id = quadcopter_rate.id
    expect(order.shipments.first.shipping_method).to eq quadcopter

    order.contents.update_cart({}) #contents don't really matter
    order.contents.advance

    expect(order.shipments.first.shipping_method).to eq quadcopter
  end

  let(:cheap_ups_cost) { 10 }

  it "reaching delivery step with no explicit selection selects cheapest shipping rate" do
    # ... even if the shipping method is created after the order
    order.contents.add(create(:variant), 1)
    cheap_ups = create(:shipping_method, name: "Cheap UPS Ground", cost: cheap_ups_cost)

    order.contents.advance
    final_selected_shipping_rate = order.shipments.first.selected_shipping_rate

    expect(final_selected_shipping_rate.shipping_method).to eq cheap_ups
    expect(final_selected_shipping_rate.cost).to eq cheap_ups_cost
  end
end
