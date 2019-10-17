# frozen_string_literal: true

require 'spec_helper'

describe "Promotion Adjustments", type: :feature, js: true do
  stub_authorization!

  context "creating a new promotion", js: true do
    before(:each) do
      visit spree.new_admin_promotion_path
      expect(page).to have_title("New Promotion - Promotions")
    end

    it "should allow an admin to create a flat rate discount coupon promo" do
      fill_in "Name", with: "SAVE SAVE SAVE"
      fill_in "Promotion Code", with: "order"

      click_button "Create"
      expect(page).to have_title("SAVE SAVE SAVE - Promotions")

      select "Item Total", from: "Discount Rules"
      within('#rule_fields') { click_button "Add" }

      find('[id$=_preferred_amount]').set(30)
      within('#rule_fields') { click_button "Update" }

      select "Create whole-order adjustment", from: "Adjustment type"
      within('#action_fields') do
        click_button "Add"
        select "Flat Rate", from: I18n.t('spree.admin.promotions.actions.calculator_label')
        fill_in "Amount", with: 5
      end
      within('#actions_container') { click_button "Update" }
      expect(page).to have_text 'successfully updated'

      promotion = Spree::Promotion.find_by(name: "SAVE SAVE SAVE")
      expect(promotion.codes.first.value).to eq("order")

      first_rule = promotion.rules.first
      expect(first_rule.class).to eq(Spree::Promotion::Rules::ItemTotal)
      expect(first_rule.preferred_amount).to eq(30)

      first_action = promotion.actions.first
      expect(first_action.class).to eq(Spree::Promotion::Actions::CreateAdjustment)
      first_action_calculator = first_action.calculator
      expect(first_action_calculator.class).to eq(Spree::Calculator::FlatRate)
      expect(first_action_calculator.preferred_amount).to eq(5)
    end

    it "should allow an admin to create a single user coupon promo with flat rate discount" do
      fill_in "Name", with: "SAVE SAVE SAVE"
      fill_in "promotion[usage_limit]", with: "1"
      fill_in "Promotion Code", with: "single_use"

      click_button "Create"
      expect(page).to have_title("SAVE SAVE SAVE - Promotions")

      select "Create whole-order adjustment", from: "Adjustment type"
      within('#action_fields') do
        click_button "Add"
        select "Flat Rate", from: I18n.t('spree.admin.promotions.actions.calculator_label')
        fill_in "Amount", with: "5"
      end
      within('#actions_container') { click_button "Update" }
      expect(page).to have_text 'successfully updated'

      promotion = Spree::Promotion.find_by(name: "SAVE SAVE SAVE")
      expect(promotion.usage_limit).to eq(1)
      expect(promotion.codes.first.value).to eq("single_use")

      first_action = promotion.actions.first
      expect(first_action.class).to eq(Spree::Promotion::Actions::CreateAdjustment)
      first_action_calculator = first_action.calculator
      expect(first_action_calculator.class).to eq(Spree::Calculator::FlatRate)
      expect(first_action_calculator.preferred_amount).to eq(5)
    end

    it "should allow an admin to create an automatic promo with flat percent discount" do
      fill_in "Name", with: "SAVE SAVE SAVE"
      choose "Apply to all orders"
      click_button "Create"
      expect(page).to have_title("SAVE SAVE SAVE - Promotions")

      select "Item Total", from: "Discount Rules"
      within('#rule_fields') { click_button "Add" }

      find('[id$=_preferred_amount]').set(30)
      within('#rule_fields') { click_button "Update" }

      select "Create whole-order adjustment", from: "Adjustment type"
      within('#action_fields') do
        click_button "Add"
        select "Flat Percent", from: I18n.t('spree.admin.promotions.actions.calculator_label')
        fill_in "Flat Percent", with: "10"
      end
      within('#actions_container') { click_button "Update" }
      expect(page).to have_text 'successfully updated'

      promotion = Spree::Promotion.find_by(name: "SAVE SAVE SAVE")
      expect(promotion.codes.first).to be_nil

      first_rule = promotion.rules.first
      expect(first_rule.class).to eq(Spree::Promotion::Rules::ItemTotal)
      expect(first_rule.preferred_amount).to eq(30)

      first_action = promotion.actions.first
      expect(first_action.class).to eq(Spree::Promotion::Actions::CreateAdjustment)
      first_action_calculator = first_action.calculator
      expect(first_action_calculator.class).to eq(Spree::Calculator::FlatPercentItemTotal)
      expect(first_action_calculator.preferred_flat_percent).to eq(10)
    end

    it "should allow an admin to create an product promo with percent per item discount" do
      create(:product, name: "RoR Mug")

      fill_in "Name", with: "SAVE SAVE SAVE"
      choose "Apply to all orders"
      click_button "Create"
      expect(page).to have_title("SAVE SAVE SAVE - Promotions")

      select "Product(s)", from: "Discount Rules"
      within("#rule_fields") { click_button "Add" }
      select2_search "RoR Mug", from: "Choose products"
      within('#rule_fields') { click_button "Update" }

      select "Create per-line-item adjustment", from: "Adjustment type"
      within('#action_fields') do
        click_button "Add"
        select "Percent Per Item", from: I18n.t('spree.admin.promotions.actions.calculator_label')
        fill_in "Percent", with: "10"
      end
      within('#actions_container') { click_button "Update" }
      expect(page).to have_text 'successfully updated'

      promotion = Spree::Promotion.find_by(name: "SAVE SAVE SAVE")
      expect(promotion.codes.first).to be_nil

      first_rule = promotion.rules.first
      expect(first_rule.class).to eq(Spree::Promotion::Rules::Product)
      expect(first_rule.products.map(&:name)).to include("RoR Mug")

      first_action = promotion.actions.first
      expect(first_action.class).to eq(Spree::Promotion::Actions::CreateItemAdjustments)
      first_action_calculator = first_action.calculator
      expect(first_action_calculator.class).to eq(Spree::Calculator::PercentOnLineItem)
      expect(first_action_calculator.preferred_percent).to eq(10)
    end

    it "should allow an admin to create an automatic promotion with free shipping (no code)" do
      fill_in "Name", with: "SAVE SAVE SAVE"
      choose "Apply to all orders"
      click_button "Create"
      expect(page).to have_title("SAVE SAVE SAVE - Promotions")

      select "Item Total", from: "Discount Rules"
      within('#rule_fields') { click_button "Add" }
      find('[id$=_preferred_amount]').set(30)
      within('#rule_fields') { click_button "Update" }

      select "Free Shipping", from: "Adjustment type"
      within('#action_fields') { click_button "Add" }
      expect(page).to have_content('Makes all shipments for the order free')

      promotion = Spree::Promotion.find_by(name: "SAVE SAVE SAVE")
      expect(promotion.codes).to be_empty
      expect(promotion.rules.first).to be_a(Spree::Promotion::Rules::ItemTotal)
      expect(promotion.actions.first).to be_a(Spree::Promotion::Actions::FreeShipping)
    end

    it "disables the button at submit", :js do
      page.execute_script "$('form').submit(function(e) { e.preventDefault()})"
      fill_in "Name", with: "SAVE SAVE SAVE"
      choose "Apply to all orders"
      click_button "Create"

      expect(page).to have_button("Create", disabled: true)
    end

    it "should allow an admin to create an automatic promotion" do
      fill_in "Name", with: "SAVE SAVE SAVE"
      choose "Apply to all orders"
      click_button "Create"
      expect(page).to have_title("SAVE SAVE SAVE - Promotions")

      promotion = Spree::Promotion.find_by(name: "SAVE SAVE SAVE")
      expect(promotion).to be_apply_automatically
      expect(promotion.path).to be_nil
      expect(promotion.codes).to be_empty
      expect(promotion.rules).to be_blank
    end

    it "should allow an admin to create a promo with generated codes" do
      fill_in "Name", with: "SAVE SAVE SAVE"
      choose "Multiple promotion codes"
      fill_in "Base code", with: "testing"
      fill_in "Number of codes", with: "10"

      perform_enqueued_jobs {
        click_button "Create"
        expect(page).to have_title("SAVE SAVE SAVE - Promotions")
      }

      promotion = Spree::Promotion.find_by(name: "SAVE SAVE SAVE")
      expect(promotion.path).to be_nil
      expect(promotion).not_to be_apply_automatically
      expect(promotion.rules).to be_blank

      expect(promotion.codes.count).to eq(10)
    end

    it "ceasing to be eligible for a promotion with item total rule then becoming eligible again" do
      fill_in "Name", with: "SAVE SAVE SAVE"
      choose "Apply to all orders"
      click_button "Create"
      expect(page).to have_title("SAVE SAVE SAVE - Promotions")

      select "Item Total", from: "Discount Rules"
      within('#rule_fields') { click_button "Add" }
      find('[id$=_preferred_amount]').set(50)
      within('#rule_fields') { click_button "Update" }

      select "Create whole-order adjustment", from: "Adjustment type"
      within('#action_fields') do
        click_button "Add"
        select "Flat Rate", from: I18n.t('spree.admin.promotions.actions.calculator_label')
        fill_in "Amount", with: "5"
      end
      within('#actions_container') { click_button "Update" }
      expect(page).to have_text 'successfully updated'

      promotion = Spree::Promotion.find_by(name: "SAVE SAVE SAVE")

      first_rule = promotion.rules.first
      expect(first_rule.class).to eq(Spree::Promotion::Rules::ItemTotal)
      expect(first_rule.preferred_amount).to eq(50)

      first_action = promotion.actions.first
      expect(first_action.class).to eq(Spree::Promotion::Actions::CreateAdjustment)
      expect(first_action.calculator.class).to eq(Spree::Calculator::FlatRate)
      expect(first_action.calculator.preferred_amount).to eq(5)
    end

    context 'creating a promotion with promotion action that has a calculator with complex preferences' do
      before do
        class ComplexCalculator < Spree::Calculator
          preference :amount, :decimal
          preference :currency, :string
          preference :mapping, :hash
          preference :list, :array

          def self.description
            "Complex Calculator"
          end
        end
        @calculators = Rails.application.config.spree.calculators.promotion_actions_create_item_adjustments
        Rails.application.config.spree.calculators.promotion_actions_create_item_adjustments = [ComplexCalculator]
      end

      after do
        Rails.application.config.spree.calculators.promotion_actions_create_item_adjustments = @calculators
      end

      it "does not show array and hash form fields" do
        fill_in "Name", with: "SAVE SAVE SAVE"
        choose "Apply to all orders"
        click_button "Create"
        expect(page).to have_title("SAVE SAVE SAVE - Promotions")

        select "Create per-line-item adjustment", from: "Adjustment type"
        within('#action_fields') do
          click_button "Add"
          select "Complex Calculator", from: I18n.t('spree.admin.promotions.actions.calculator_label')
        end
        within('#actions_container') { click_button "Update" }
        expect(page).to have_text 'successfully updated'

        within('#action_fields') do
          expect(page).to have_field('Amount')
          expect(page).to have_field('Currency')
          expect(page).to_not have_field('Mapping')
          expect(page).to_not have_field('List')
        end
      end
    end
  end
end
