require 'spec_helper'

module Spree
  RSpec.describe OrderUpdateAttributes do
    let(:order) { create(:order) }
    let(:request_env) { nil }
    let(:update) { described_class.new(order, attributes, request_env: request_env) }

    context 'empty attributes' do
      let(:attributes){ {} }
      it 'succeeds' do
        expect(update.apply).to be_truthy
      end
    end

    context 'with coupon code' do
      let(:attributes){ { coupon_code: 'abc123' } }
      it "sets coupon code" do
        expect(update.apply).to be_truthy
        expect(order.coupon_code).to eq('abc123')
      end
    end

    context 'with payment attributes' do
      let(:attributes) do
        {
          payments_attributes: [
            { source_attributes: attributes_for(:credit_card) }
          ]
        }
      end

      context 'with params and a request_env' do
        let(:request_env){ { 'USER_AGENT' => 'Firefox' } }
        it 'sets the request_env on the payment' do
          expect(update.apply).to be_truthy
          expect(order.payments.length).to eq 1
          expect(order.payments[0].request_env).to eq({ 'USER_AGENT' => 'Firefox' })
        end
      end
    end

    context 'when changing shipping method' do
      let!(:order) { create(:order_with_line_items, shipping_method: shipping_method1) }
      let(:shipment){ order.shipments.first }
      let!(:zone) { create(:zone) }
      let!(:shipping_method1){ create(:shipping_method, cost: 10, zones: [zone]) }
      let!(:shipping_method2){ create(:shipping_method, cost: 20, zones: [zone]) }

      let(:attributes) do
        {
          shipments_attributes: {
            0 => { selected_shipping_rate_id: shipping_method2, id: shipment.id }
          }
        }
      end

      it "updates shipment costs" do
        zone.zone_members.create!(zoneable: order.ship_address.country)
        order.create_proposed_shipments
        order.set_shipments_cost

        shipping_rate2 = shipment.shipping_rates.find_by(shipping_method_id: shipping_method2.id)

        expect(order.shipment_total).to eq(10)

        # We need an order which doesn't have shipping_rates loaded
        order.reload

        described_class.new(
          order,
          shipments_attributes: {
            0 => { selected_shipping_rate_id: shipping_rate2.id, id: shipment.id }
          }
        ).apply

        expect(order.shipment_total).to eq(20)
        expect(order.shipments.first.cost).to eq(20)
      end
    end
  end
end
