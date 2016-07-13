require 'spec_helper'

describe Spree::Admin::CancellationsController do
  stub_authorization!

  describe "#index" do
    subject { get :index, order_id: order.number }

    let(:order) { create(:order_ready_to_ship, line_items_count: 1) }

    context "for an order with inventory" do
      render_views

      it "succeeds" do
        expect(response).to be_ok
      end
    end
  end

  describe "#cancel" do
    subject { post :short_ship, order_id: order.number, inventory_unit_ids: inventory_units.map(&:id) }

    let(:order) { create(:order_ready_to_ship, number: "R100", state: "complete", line_items_count: 1) }
    let(:referer) { "order_admin_page" }

    context "no inventory unit ids are provided" do
      subject { post :short_ship, order_id: order.number }

      it "redirects back" do
        subject
        expect(response).to redirect_to(spree.admin_order_cancellations_path(order))
      end

      it "sets an error message" do
        subject
        expect(flash[:error]).to eq Spree.t(:no_inventory_selected)
      end
    end

    context "unable to find all the inventory" do
      let(:inventory_units) { [Spree::InventoryUnit.new(id: -1)] }

      it "redirects back" do
        subject
        expect(response).to redirect_to(spree.admin_order_cancellations_path(order))
      end

      it "sets an error message" do
        subject
        expect(flash[:error]).to eq Spree.t(:unable_to_find_all_inventory_units)
      end
    end

    context "successfully cancels inventory" do
      let(:inventory_units) { order.inventory_units.not_canceled }

      it "redirects to admin order edit" do
        subject
        expect(response).to redirect_to(spree.edit_admin_order_path(order))
      end

      it "sets an success message" do
        subject
        expect(flash[:success]).to eq Spree.t(:inventory_canceled)
      end

      it "creates a unit cancel" do
        expect { subject }.to change { Spree::UnitCancel.count }.by(1)
      end

      it "cancels the inventory" do
        subject
        expect(order.inventory_units.map(&:state).uniq).to match_array(['canceled'])
      end
    end
  end
end
