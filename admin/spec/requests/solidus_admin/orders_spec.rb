# frozen_string_literal: true

require "spec_helper"

RSpec.describe "SolidusAdmin::OrdersController", type: :request do
  let(:admin_user) { create(:admin_user) }

  before do
    allow(SolidusAdmin::Config).to receive(:enable_alpha_features?).and_return(true)
    allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)
  end

  describe "GET #index" do
    around do |example|
      original_per_page = SolidusAdmin::Config[:pagination_ratios_per_page]
      SolidusAdmin::Config[:pagination_ratios_per_page] = [1, 2, 3, 4]
      example.run
      SolidusAdmin::Config[:pagination_ratios_per_page] = original_per_page
    end

    it "paginates resources on first page based on pagination config" do
      orders = create_list(:completed_order_with_totals, 4)
      orders.sort_by!(&:completed_at).reverse!

      get solidus_admin.orders_path
      expect(response).to have_http_status(:ok)

      expect(response.body).to include(orders[0].number)
      expect(response.body).to_not include(orders[1].number)
      expect(response.body).to_not include(orders[2].number)
      expect(response.body).to_not include(orders[3].number)
    end

    it "paginates resources on second page based on pagination config" do
      orders = create_list(:completed_order_with_totals, 4)
      orders.sort_by!(&:completed_at).reverse!

      get solidus_admin.orders_path(params: {page: 2})
      expect(response).to have_http_status(:ok)

      expect(response.body).to_not include(orders[0].number)
      expect(response.body).to include(orders[1].number)
      expect(response.body).to include(orders[2].number)
      expect(response.body).to_not include(orders[3].number)
    end
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
end
