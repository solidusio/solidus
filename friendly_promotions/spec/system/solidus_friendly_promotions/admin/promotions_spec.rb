# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "Promotions admin", type: :system do
  stub_authorization!

  describe "#index" do
    let!(:promotion1) { create(:promotion, :with_action, name: "name1", code: "code1", path: "path1") }
    let!(:promotion2) { create(:promotion, :with_action, name: "name2", code: "code2", path: "path2") }
    let!(:promotion3) do
      create(:promotion, :with_action, name: "name3", code: "code3", path: "path3", expires_at: Date.yesterday)
    end
    let!(:category) { create :promotion_category }

    it "succeeds" do
      visit solidus_friendly_promotions.admin_promotions_path
      [promotion3, promotion2, promotion1].map(&:name).each do |promotion_name|
        expect(page).to have_content promotion_name
      end
    end

    it "shows promotion categories" do
      visit solidus_friendly_promotions.admin_promotions_path
      expect(page).to have_select(Spree::PromotionCategory.model_name.human, options: ["All", category.name])
    end

    context "search" do
      it "pages results" do
        visit solidus_friendly_promotions.admin_promotions_path(per_page: '1')
        expect(page).to have_content(promotion3.name)
        expect(page).not_to have_content(promotion1.name)
      end

      it "filters by name" do
        visit solidus_friendly_promotions.admin_promotions_path(q: { name_cont: promotion1.name })
        expect(page).to have_content(promotion1.name)
        expect(page).not_to have_content(promotion2.name)
      end

      it "filters by code" do
        visit solidus_friendly_promotions.admin_promotions_path(q: { codes_value_cont: promotion1.codes.first.value })
        expect(page).to have_content(promotion1.name)
        expect(page).not_to have_content(promotion2.name)
      end

      it "filters by path" do
        visit solidus_friendly_promotions.admin_promotions_path(q: { path_cont: promotion1.path })
        expect(page).to have_content(promotion1.name)
        expect(page).not_to have_content(promotion2.name)
      end

      it "filters by active" do
        visit solidus_friendly_promotions.admin_promotions_path(q: { active: true })
        expect(page).to have_content(promotion1.name)
        expect(page).to have_content(promotion2.name)
        expect(page).not_to have_content(promotion3.name)
      end
    end
  end

  describe "Creating a promotion" do
    it "allows creating a promotion with the new UI" do
      visit solidus_friendly_promotions.admin_promotions_path
      click_link "New Promotion"
      expect(page).to have_field("Name")
      expect(page).to have_field("Start")
      expect(page).to have_field("End")
      expect(page).to have_field("Description")
      fill_in("Name", with: "20 percent off")
      fill_in("Start", with: Time.current)
      fill_in("End", with: 1.week.from_now)
      choose("Apply to all orders")
      click_button("Create")
      expect(page).to have_content("20 percent off")
    end
  end
end
