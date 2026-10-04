# frozen_string_literal: true

require "spec_helper"

RSpec.describe "SolidusAdmin::OrdersController", type: :request do
  let(:admin_user) { create(:admin_user) }

  before do
    allow(SolidusAdmin::Config).to receive(:enable_alpha_features?).and_return(true)
    allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)
  end

  describe "GET #show" do
    let(:order) { create(:completed_order_with_totals, line_items_count: 3) }

    it "renders successfully" do
      get solidus_admin.order_path(order)
      expect(response).to have_http_status(:ok)
    end

    it "loads line item variants in a single query" do
      order
      expect { get solidus_admin.order_path(order) }
        .to make_database_queries(matching: /from .spree_variants..*\bid. IN \(/im, count: 1)
    end
  end

  describe "PATCH #update" do
    let(:order) { create(:order) }
    let(:customer) { create(:user) }

    it "assigns the customer to the order" do
      expect {
        patch solidus_admin.order_path(order), params: {order: {user_id: customer.id}}
      }.to change { order.reload.user }.to(customer)
    end

    context "when the admin cannot see users" do
      before do
        ability = Class.new do
          include CanCan::Ability

          def initialize
            can :manage, Spree::Order
          end
        end.new

        allow_any_instance_of(SolidusAdmin::BaseController).to receive(:current_ability).and_return(ability)
      end

      it "does not assign the customer to the order" do
        expect {
          patch solidus_admin.order_path(order), params: {order: {user_id: customer.id}}
        }.to raise_error(ActiveRecord::RecordNotFound)

        expect(order.reload.user).not_to eq(customer)
      end

      it "still updates an order when the current customer is resubmitted" do
        expect {
          patch solidus_admin.order_path(order), params: {order: {user_id: order.user_id, email: "changed@example.com"}}
        }.to change { order.reload.email }.to("changed@example.com")
      end
    end
  end
end
