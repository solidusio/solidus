# frozen_string_literal: true

require "spec_helper"

describe Spree::Admin::OrdersHelper, type: :helper do
  describe "#event_links" do
    subject { helper.event_links }

    before do
      helper.class.include Spree::Admin::NavigationHelper
      helper.class.include Spree::Core::Engine.routes.url_helpers
      @order_events = %w{approve cancel resume}
    end

    context "with an uncompleted order" do
      before do
        @order = create(:order)
      end

      it "renders link to approve order" do
        is_expected.to have_button("Approve")
      end
    end

    context "with a complete order" do
      before do
        @order = create(:completed_order_with_totals)
      end

      it "renders link to approve order" do
        is_expected.to have_button("Approve")
      end

      it "renders link to cancel order" do
        is_expected.to have_button("Cancel")
      end
    end

    context "with a canceled order" do
      before do
        @order = create(:completed_order_with_totals).tap(&:cancel!)
      end

      it "renders link to approve order" do
        is_expected.to have_button("Approve")
      end

      it "renders link to resume order" do
        is_expected.to have_button("Resume")
      end
    end
  end
end
