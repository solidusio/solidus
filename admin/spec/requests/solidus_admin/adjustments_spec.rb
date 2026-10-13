# frozen_string_literal: true

require "spec_helper"

RSpec.describe "SolidusAdmin::AdjustmentsController", type: :request do
  let(:admin_user) { create(:admin_user) }
  let(:order) { create(:order) }

  before do
    allow(SolidusAdmin::Config).to receive(:enable_alpha_features?).and_return(true)
    allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)
  end

  describe "GET /index" do
    it "lists every adjustment on a single page" do
      stub_const("SolidusAdmin::ControllerHelpers::Pagination::DEFAULT_PER_PAGE", 2)
      create_list(:adjustment, 3, order:)

      get solidus_admin.order_adjustments_path(order)

      expect(response).to have_http_status(:ok)
      expect(Nokogiri::HTML(response.body).css("table tbody tr").size).to eq(3)
      expect(response.body).not_to include('rel="next"')
    end
  end
end
