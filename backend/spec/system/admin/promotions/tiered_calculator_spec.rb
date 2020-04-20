# frozen_string_literal: true

require 'spec_helper'

feature "Tiered Calculator Promotions" do
  stub_authorization!

  let(:promotion) { create :promotion }

  background do
    visit spree.edit_admin_promotion_path(promotion)
  end

  scenario "adding a tiered percent calculator", js: true do
    select "Create whole-order adjustment", from: "Adjustment type"
    within('#action_fields') { click_button "Add" }

    select "Tiered Percent", from: I18n.t('spree.admin.promotions.actions.calculator_label')
    within('#actions_container') { click_button "Update" }

    within("#actions_container .settings") do
      expect(page).to have_content("Base Percent")
      expect(page).to have_content("Tiers")

      page.find('a.button').click
    end

    fill_in "Base Percent", with: 5

    within(".tier") do
      find("input:last-child").set(100)
      find("input:first-child").set(10)
    end

    within('#actions_container') { click_button "Update" }

    first_action = promotion.actions.first
    expect(first_action.class).to eq Spree::Promotion::Actions::CreateAdjustment

    first_action_calculator = first_action.calculator
    expect(first_action_calculator.class).to eq Spree::Calculator::TieredPercent
    expect(first_action_calculator.preferred_base_percent).to eq 5
    expect(first_action_calculator.preferred_tiers).to eq(BigDecimal(100) => BigDecimal(10))
  end

  context "with an existing tiered flat rate calculator" do
    let(:promotion) { create :promotion, :with_order_adjustment }

    background do
      action = promotion.actions.first

      action.calculator = Spree::Calculator::TieredFlatRate.new
      action.calculator.preferred_base_amount = 5
      action.calculator.preferred_tiers = { 100 => 10, 200 => 15, 300 => 20 }
      action.calculator.save!

      visit spree.edit_admin_promotion_path(promotion)
    end

    scenario "deleting a tier", js: true do
      within(".tier:nth-child(2)") do
        find(".remove").click
      end

      within('#actions_container') { click_button "Update" }

      expect(page).to have_text('has been successfully updated!')

      calculator = promotion.actions.first.calculator
      expect(calculator.preferred_tiers).to eq({
        BigDecimal(100) => 10,
        BigDecimal(300) => 20
      })
    end
  end
end
