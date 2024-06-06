# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Orders Listing", type: :feature, js: true do
  stub_authorization!

  before(:each) do
    allow_any_instance_of(Spree::OrderInventory).to receive(:add_to_shipment)
    @order1 = create(:order_with_line_items, created_at: 1.day.from_now, completed_at: 1.day.from_now, number: "R100")
    @order2 = create(:order, created_at: 1.day.ago, completed_at: 1.day.ago, number: "R200")
    visit spree.admin_orders_path
  end

  context "searching orders" do
    context "filter on promotions" do
      let!(:promotion) { create(:promotion_with_item_adjustment, code: "vnskseiw") }
      let(:promotion_code) { promotion.codes.first }

      before(:each) do
        @order1.order_promotions.build(
          promotion: promotion,
          promotion_code: promotion_code
        )
        @order1.save
        visit spree.admin_orders_path
      end

      it "only shows the orders with the selected promotion" do
        click_on "Filter Results"
        fill_in "q_order_promotions_promotion_code_value_start", with: promotion.codes.first.value
        click_on 'Filter Results'
        within_row(1) { expect(page).to have_content("R100") }
        within("table#listing_orders") { expect(page).not_to have_content("R200") }
      end
    end
  end
end
