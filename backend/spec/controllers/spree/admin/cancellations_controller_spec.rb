# frozen_string_literal: true

require 'spec_helper'

describe Spree::Admin::CancellationsController do
  stub_authorization!

  describe "#index" do
    subject { get :index, params: { order_id: order.number } }

    let(:order) { create(:order_ready_to_ship, line_items_count: 1) }

    context "for an order with inventory" do
      render_views

      it "succeeds" do
        expect(response).to be_ok
      end
    end
  end

  describe "#cancel" do
    subject { post :short_ship, params: { order_id: order.number, inventory_unit_ids: inventory_units.map(&:id) } }

    let(:order) { create(:order_with_line_items, line_items_attributes: [{ quantity: 4 }]) }
    let(:referer) { "order_admin_page" }

    context "no inventory unit ids are provided" do
      subject { post :short_ship, params: { order_id: order.number } }

      it "redirects back" do
        subject
        expect(response).to redirect_to(spree.admin_order_cancellations_path(order))
      end

      it "sets an error message" do
        subject
        expect(flash[:error]).to eq I18n.t('spree.no_inventory_selected')
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
        expect(flash[:error]).to eq I18n.t('spree.unable_to_find_all_inventory_units')
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
        expect(flash[:success]).to eq I18n.t('spree.inventory_canceled')
      end

      it "creates a unit cancel" do
        expect { subject }.to change { Spree::UnitCancel.count }.by(4)
      end

      it "cancels the inventory" do
        subject
        expect(order.reload.inventory_units.map(&:state).uniq).to match_array(['canceled'])
      end

      it "adjusts the order" do
        expect { subject }.to change { order.reload.total }.by(-40.0)
      end
    end
  end
end
