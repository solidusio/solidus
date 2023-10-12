# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Promotions admin", type: :system do
  stub_authorization!

  describe "#index" do
    let!(:promotion1) do
      create(:friendly_promotion, :with_adjustable_action, name: "name1", code: "code1", path: "path1")
    end
    let!(:promotion2) do
      create(:friendly_promotion, :with_adjustable_action, name: "name2", code: "code2", path: "path2")
    end
    let!(:promotion3) do
      create(
        :friendly_promotion,
        :with_adjustable_action,
        name: "name3",
        code: "code3",
        path: "path3",
        expires_at: Date.yesterday
      )
    end
    let!(:category) { create :friendly_promotion_category }

    it "succeeds" do
      visit solidus_friendly_promotions.admin_promotions_path
      [promotion3, promotion2, promotion1].map(&:name).each do |promotion_name|
        expect(page).to have_content promotion_name
      end
    end

    it "shows promotion categories" do
      visit solidus_friendly_promotions.admin_promotions_path
      expect(page).to have_select(
        SolidusFriendlyPromotions::PromotionCategory.model_name.human,
        options: ["All", category.name]
      )
    end

    context "search" do
      it "pages results" do
        visit solidus_friendly_promotions.admin_promotions_path(per_page: "1")
        expect(page).to have_content(promotion3.name)
        expect(page).not_to have_content(promotion1.name)
      end

      it "filters by name" do
        visit solidus_friendly_promotions.admin_promotions_path(q: {name_cont: promotion1.name})
        expect(page).to have_content(promotion1.name)
        expect(page).not_to have_content(promotion2.name)
      end

      it "filters by code" do
        visit solidus_friendly_promotions.admin_promotions_path(q: {codes_value_cont: promotion1.codes.first.value})
        expect(page).to have_content(promotion1.name)
        expect(page).not_to have_content(promotion2.name)
      end

      it "filters by path" do
        visit solidus_friendly_promotions.admin_promotions_path(q: {path_cont: promotion1.path})
        expect(page).to have_content(promotion1.name)
        expect(page).not_to have_content(promotion2.name)
      end

      it "filters by active" do
        visit solidus_friendly_promotions.admin_promotions_path(q: {active: true})
        expect(page).to have_content(promotion1.name)
        expect(page).to have_content(promotion2.name)
        expect(page).not_to have_content(promotion3.name)
      end
    end
  end

  describe "Creating a promotion" do
    it "allows creating a promotion with the new UI", :js do
      visit solidus_friendly_promotions.admin_promotions_path
      click_link "New Promotion"
      expect(page).to have_field("Name")
      expect(page).to have_field("Starts at")
      expect(page).to have_field("Expires at")
      expect(page).to have_field("Description")
      fill_in("Name", with: "March 2023 Giveaway")
      fill_in("Customer-facing label", with: "20 percent off")
      fill_in("Starts at", with: Time.current)
      fill_in("Expires at", with: 1.week.from_now)
      choose("Apply to all orders")
      click_button("Create")
      expect(page).to have_content("March 2023 Giveaway")
      promotion = SolidusFriendlyPromotions::Promotion.first
      within("#new_order_promotion_rule_promotion_#{promotion.id}") do
        click_link("New Rule")
        select("First Order", from: "Type")
        click_button("Add")
      end
      expect(page).to have_content("Must be the customer's first order")
      expect(SolidusFriendlyPromotions::PromotionRule.first).to be_a(SolidusFriendlyPromotions::Rules::FirstOrder)
      promotion_rule = promotion.rules.first
      within("#rules_first_order_#{promotion_rule.id}") do
        find(".delete").click
      end
      expect(page).not_to have_content("Must be the customer's first order")
      expect(promotion.rules).to be_empty

      within("#new_order_promotion_rule_promotion_#{promotion.id}") do
        click_link("New Rule")
        select("Item Total", from: "Type")
        fill_in("promotion_rule_preferred_amount", with: 200)
        click_button("Add")
      end

      expect(page).to have_content("Order total meets these criteria")

      promotion_rule = promotion.rules.first
      within("#rules_item_total_#{promotion_rule.id}") do
        expect(find("#promotion_rule_preferred_amount").value).to eq("200.00")
        fill_in("promotion_rule_preferred_amount", with: 300)
        click_button("Update")
        expect(find("#promotion_rule_preferred_amount").value).to eq("300.00")
      end

      within("#new_promotion_action_promotion_#{promotion.id}") do
        click_link("New Action")
        select("Discount matching line items", from: "Type")
        select("Flat Rate", from: "Calculator type")
        fill_in("promotion_action_calculator_attributes_preferred_amount", with: 20)
        click_button("Add")
      end
      expect(page).to have_selector("h6", text: "Discount matching line items")
      action = promotion.actions.first

      within("#actions_adjust_line_item_#{action.id}_promotion_#{promotion.id}") do
        fill_in("promotion_action_calculator_attributes_preferred_amount", with: 30)
        click_button("Update")
      end
      expect(action.reload.calculator.preferred_amount).to eq(30)

      within("#actions_adjust_line_item_#{action.id}_promotion_#{promotion.id}") do
        find(".delete").click
      end
      expect(page).to have_content("Promotion action has been successfully removed!")
    end
  end
end
