require 'spec_helper'

describe Spree::Shipment::ProposedShipmentsCreator do
  let(:order) { create(:order_with_line_items) }
  let(:shipment_creator) { Spree::Shipment::ProposedShipmentsCreator.new(order) }

  describe "#shipments" do

    subject { shipment_creator.shipments }

    it "assigns the coordinator returned shipments to its shipments" do
      shipment = build(:shipment)
      allow_any_instance_of(Spree::Stock::Coordinator).to receive(:shipments).and_return([shipment])
      expect(subject).to eq [shipment]
    end

    it "raises an error if any shipments are ready" do
      shipment = create(:shipment, order: order, state: "ready")
      expect {
        expect {
          subject
        }.to raise_error(Spree::Shipment::ProposedShipmentsCreator::CannotRebuildShipments)
      }.not_to change { order.reload.shipments }

      expect { shipment.reload }.not_to raise_error
    end

    it "raises an error if any shipments are shipped" do
      shipment = create(:shipment, order: order, state: "shipped")
      expect {
        expect {
          subject
        }.to raise_error(Spree::Shipment::ProposedShipmentsCreator::CannotRebuildShipments)
      }.not_to change { order.reload.shipments }

      expect { shipment.reload }.not_to raise_error
    end

    context "shipping method handler is defined" do
      before do
        Spree::Shipment::ProposedShipmentsCreator.shipping_method_handler = -> (proposed_shipments, original_shipping_methods) { raise "TestError" }
      end

      after do
        Spree::Shipment::ProposedShipmentsCreator.shipping_method_handler = -> (proposed_shipments, original_shipping_methods) { }
      end

      it "calls the shipping method handler after the shipments are created" do
        shipment = build(:shipment)
        allow_any_instance_of(Spree::Stock::Coordinator).to receive(:shipments).and_return([shipment])
        expect { subject }.to raise_error("TestError")
      end
    end
  end
end
