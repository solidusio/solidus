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
      expect { get solidus_admin.order_path(order) }
        .to make_database_queries(matching: /from .spree_variants..*\bid. IN \(/im, count: 1)
    end
  end
end
