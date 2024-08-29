# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Promotions admin" do
  stub_authorization!

  describe "#index" do
    let!(:promotion1) do
      create(:solidus_promotion, :with_adjustable_benefit, name: "name1", code: "code1", path: "path1", lane: "pre", updated_at: 2.days.ago)
    end
    let!(:promotion2) do
      create(:solidus_promotion, :with_adjustable_benefit, name: "name2", code: "code2", path: "path2", lane: "default", updated_at: 10.days.ago)
    end
    let!(:promotion3) do
      create(
        :solidus_promotion,
        :with_adjustable_benefit,
        lane: "post",
        name: "name3",
        code: "code3",
        path: "path3",
        updated_at: 5.days.ago,
        expires_at: Date.yesterday
      )
    end
    let!(:inactive_promotion) { create(:solidus_promotion, name: "My inactive Promotion", starts_at: 1.day.ago, updated_at: 20.days.ago) }

    let!(:category) { create :solidus_promotion_category }

    it "succeeds" do
      visit solidus_promotions.admin_promotions_path
      [promotion3, promotion2, promotion1].map(&:name).each do |promotion_name|
        expect(page).to have_content promotion_name
      end
    end

    it "shows promotion categories" do
      visit solidus_promotions.admin_promotions_path
      expect(page).to have_select(
        SolidusPromotions::PromotionCategory.model_name.human,
        options: ["All", category.name]
      )
    end

    describe "search" do
      it "pages results" do
        visit solidus_promotions.admin_promotions_path(per_page: "1")
        expect(page).to have_content(promotion1.name)
        expect(page).not_to have_content(promotion3.name)
      end

      it "filters by name" do
        visit solidus_promotions.admin_promotions_path(q: {name_cont: promotion1.name})
        expect(page).to have_content(promotion1.name)
        expect(page).not_to have_content(promotion2.name)
      end

      it "filters by code" do
        visit solidus_promotions.admin_promotions_path(q: {codes_value_cont: promotion1.codes.first.value})
        expect(page).to have_content(promotion1.name)
        expect(page).not_to have_content(promotion2.name)
      end

      it "filters by path" do
        visit solidus_promotions.admin_promotions_path(q: {path_cont: promotion1.path})
        expect(page).to have_content(promotion1.name)
        expect(page).not_to have_content(promotion2.name)
      end

      it "filters by active date" do
        visit solidus_promotions.admin_promotions_path(q: {active: Time.current})
        expect(page).to have_content(promotion1.name)
        expect(page).to have_content(promotion2.name)
        expect(page).not_to have_content(promotion3.name)
      end

      it "filters by active the day before yesterday" do
        visit solidus_promotions.admin_promotions_path(q: {active: 2.days.ago})
        expect(page).to have_content(promotion1.name)
        expect(page).to have_content(promotion2.name)
        expect(page).to have_content(promotion3.name)
      end

      it "filters by lane" do
        visit solidus_promotions.admin_promotions_path(q: {lane_eq: :pre})
        expect(page).to have_content(promotion1.name)
        expect(page).not_to have_content(promotion2.name)
        expect(page).not_to have_content(promotion3.name)
      end

      it "sorts by updated_at by default" do
        visit solidus_promotions.admin_promotions_path
        expect(page.text).to match(/.*name1.*name3.*name2.*/m)
      end
    end
  end

  describe "Creating a promotion" do
    it "allows creating a promotion with the new UI", :js do
      visit solidus_promotions.admin_promotions_path
      click_link "New Promotion"
      expect(page).to have_field("Name")
      expect(page).to have_field("Starts at")
      expect(page).to have_field("Expires at")
      expect(page).to have_field("Description")
      fill_in("Name", with: "March 2023 Giveaway")
      fill_in("Customer-facing label", with: "20 percent off")
      fill_in("Starts at", with: Time.current)
      fill_in("Expires at", with: 1.week.from_now)
      check("Apply automatically")
      click_button("Create")
      expect(page).to have_content("March 2023 Giveaway")
      promotion = SolidusPromotions::Promotion.first

      within("#new_benefit_promotion_#{promotion.id}") do
        click_link("Add Benefit")
        select("Discount matching line items", from: "Type")
        select("Flat Rate", from: "Calculator type")
        fill_in("benefit_calculator_attributes_preferred_amount", with: 20)
        click_button("Add")
      end
      expect(page).to have_selector(".card-header", text: "Discount matching line items")
      benefit = promotion.benefits.first

      within("#benefits_adjust_line_item_#{benefit.id}_promotion_#{promotion.id}") do
        fill_in("benefit_calculator_attributes_preferred_amount", with: 30)
        click_button("Update")
      end
      expect(page).to have_content("Benefit has been successfully updated!")
      expect(benefit.reload.calculator.preferred_amount).to eq(30)

      click_link("Add Condition")
      select("First Order", from: "Condition Type")
      click_button("Add")
      expect(page).to have_content("Must be the customer's first order")
      expect(SolidusPromotions::Condition.first).to be_a(SolidusPromotions::Conditions::FirstOrder)
      within("#benefits_adjust_line_item_#{benefit.id}_conditions") do
        find(".delete").click
      end
      expect(page).not_to have_content("Must be the customer's first order")
      expect(promotion.conditions).to be_empty

      click_link("Add Condition")
      select("Item Total", from: "Condition Type")
      fill_in("condition_preferred_amount", with: 200)
      click_button("Add")

      expect(page).to have_content("Order total must be greater than or equal to the specified amount")

      within("#benefits_adjust_line_item_#{benefit.id}_conditions") do
        expect(find("#condition_preferred_amount").value).to eq("200.00")
        fill_in("condition_preferred_amount", with: 300)
        click_button("Update")
        expect(find("#condition_preferred_amount").value).to eq("300.00")
      end

      within("#benefits_adjust_line_item_#{benefit.id}_header") do
        find(".delete").click
      end
      expect(page).to have_content("Benefit has been successfully removed!")
    end
  end
end
