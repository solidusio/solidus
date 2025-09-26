# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Promotion with option value rule" do
  stub_authorization!

  given(:variant) { create :variant }
  given!(:product) { variant.product }
  given!(:option_value) { variant.option_values.first }

  given(:promotion) { create :promotion }

  background do
    visit spree.edit_admin_promotion_path(promotion)
  end

  scenario "adding an option value rule", js: true do
    select "Option Value(s)", from: "Discount Rules"
    within("#rules_container") { click_button "Add" }

    within("#rules_container .promotion-block") do
      expect(page).to have_content("Product")
      expect(page).to have_content("Option Values")

      click_button "Add"
    end

    within(".promo-rule-option-value") do
      targetted_select2_search product.name, from: ".js-promo-rule-option-value-product-select"
      targetted_select2_search option_value.name, from: ".js-promo-rule-option-value-option-values-select"
    end

    within("#rules_container") { click_button "Update" }

    expect(page).to have_content("has been successfully updated")

    first_rule = promotion.rules.reload.first
    expect(first_rule.class).to eq Spree::Promotion::Rules::OptionValue
    expect(first_rule.preferred_eligible_values).to eq({product.id => [option_value.id]})
  end

  context "with an attempted XSS" do
    let(:xss_string) { %(<script>throw("XSS")</script>) }
    before do
      option_value.update!(name: xss_string)
    end
    scenario "adding an option value rule", js: true do
      select "Option Value(s)", from: "Discount Rules"
      within("#rules_container") { click_button "Add" }

      within("#rules_container .promotion-block") do
        click_button "Add"
      end

      within(".promo-rule-option-value") do
        targetted_select2_search product.name, from: ".js-promo-rule-option-value-product-select"
        targetted_select2_search option_value.name, from: ".js-promo-rule-option-value-option-values-select"
      end
    end
  end

  context "with an existing option value rule" do
    given(:variant1) { create :variant }
    given(:variant2) { create :variant }
    background do
      rule = Spree::Promotion::Rules::OptionValue.new
      rule.promotion = promotion
      rule.preferred_eligible_values(= {variant1.product_id => variant1.option_values.pluck(:id),
        variant2.product_id => variant2.option_values.pluck(:id)})
      rule.save!

      visit spree.edit_admin_promotion_path(promotion)
    end

    scenario "deleting a product", js: true do
      expect(page).to have_css(".promo-rule-option-value", count: 2)
      all(".promo-rule-option-value")[1].find(".remove").click

      within("#rules_container") { click_button "Update" }

      expect(page).to have_content("has been successfully updated")

      first_rule = promotion.rules.reload.first
      expect(first_rule.preferred_eligible_values).to eq({variant1.product_id => variant1.option_values.pluck(:id)})
    end
  end
end
