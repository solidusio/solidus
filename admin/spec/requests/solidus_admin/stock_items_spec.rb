# frozen_string_literal: true

require "spec_helper"

RSpec.describe "SolidusAdmin::StockItemsController", type: :request do
  let(:admin_user) { create(:admin_user) }

  before do
    allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)
  end

  describe "GET #index" do
    it "loads stock item stock locations in a single query" do
      3.times do
        location = create(:stock_location, propagate_all_variants: false)
        create(:stock_item, stock_location: location, variant: create(:variant))
      end

      expect { get solidus_admin.stock_items_path }.to make_database_queries(matching: /from .spree_stock_locations./i, count: 2)
    end
  end
end
