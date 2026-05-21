# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Automatic promotions', type: :system, js: true do
  let!(:store) { create(:store) }
  let!(:product) do
    create(:product, name: "Solidus mug set", price: 20).tap do |product|
      product.master.stock_items.update_all count_on_hand: 10
    end
  end

  let!(:promotion) do
    promotion = Spree::Promotion.create!(name: "$10 off when you spend more than $100", apply_automatically: true)

    calculator = Spree::Calculator::FlatRate.new
    calculator.preferred_amount = 10

    rule = Spree::Promotion::Rules::ItemTotal.create
    rule.preferred_amount = 100
    rule.save

    promotion.rules << rule

    action = Spree::Promotion::Actions::CreateAdjustment.create
    action.calculator = calculator
    action.save

    promotion.actions << action
  end

  context "on the cart page" do
    before do
      visit products_path
      click_link product.name
      click_button "add-to-cart-button"
    end

    it "automatically applies the promotion once the order crosses the threshold" do
      fill_in "order_line_items_attributes_0_quantity", with: 6
      click_button "Update"
      expect(page).to have_content("Promotion ($10 off when you spend more than $100) -$10.00", normalize_ws: true)

      fill_in "order_line_items_attributes_0_quantity", with: 5
      click_button "Update"
      expect(page).not_to have_content("Promotion ($10 off when you spend more than $100) -$10.00", normalize_ws: true)
    end
  end
end
