require 'spec_helper'

describe Spree::Carton do
  let(:carton) { create(:carton) }

  describe "#create" do
    subject { carton }

    it { expect { subject }.to_not raise_error }
  end

  describe "#tracking_url" do
    subject do
      carton.tracking_url
    end

    let(:carton) { create(:carton, shipping_method: shipping_method) }
    let(:shipping_method) do
      create(:shipping_method, tracking_url: "https://example.com/:tracking")
    end

    context "when tracking is not present" do
      it { is_expected.to be_nil }
    end

    context "when tracking is present" do
      let(:carton) do
        create(:carton, shipping_method: shipping_method, tracking: "1Z12345")
      end

      it "uses shipping method to determine url" do
        is_expected.to eq("https://example.com/1Z12345")
      end
    end
  end

  describe "#to_param" do
    subject do
      carton.to_param
    end

    it { is_expected.to eq carton.number }
  end

  describe "#order_numbers" do
    subject { carton.order_numbers }
    let(:order) { carton.orders.first }

    it "returns a list of the order numbers it is associated to" do
      expect(subject).to eq [order.number]
    end
  end

  describe "#shipment_numbers" do
    subject { carton.shipment_numbers }
    let(:shipment) { carton.shipments.first }

    it "returns a list of the order numbers it is associated to" do
      expect(subject).to eq [shipment.number]
    end
  end

  describe "#order_emails" do
    subject { carton.order_emails }

    let(:carton) { create(:carton, inventory_units: [first_order.inventory_units, second_order.inventory_units].flatten) }
    let(:first_order) { create(:order_ready_to_ship, line_items_count: 1) }
    let(:second_order) { create(:order_ready_to_ship, line_items_count: 1) }
    let(:email) { 'something@something.com' }

    before do
      first_order.update_attributes!(email: email)
      second_order.update_attributes!(email: email)
    end

    it "returns a unique list of the order emails it is associated to" do
      expect(subject).to eq [email]
    end
  end

end
