# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Order", :js, type: :feature, solidus_admin: true do
  let(:admin) { create(:admin_user) }
  let(:order) { create(:order, number: "R123456789") }

  before do
    allow(SolidusAdmin::Config).to receive(:enable_alpha_features?) { true }
    sign_in admin
  end

  context "with a promotion adjustment" do
    let(:order) { create(:order_ready_to_ship, number: "R123456789") }
    let(:promotion) { create(:promotion, :with_adjustable_action) }

    before do
      Spree::Adjustment.create!(
        order: order,
        source: promotion.actions.first,
        adjustable: order.line_items.first,
        amount: 2,
        label: "Promotion Adjustment"
      )
    end

    it "can display the adjustment" do
      visit "/admin/orders/R123456789"

      click_on "Adjustments"
      expect(page).to have_content("Promotion Adjustment")
      expect(page).to be_axe_clean
    end
  end
end
