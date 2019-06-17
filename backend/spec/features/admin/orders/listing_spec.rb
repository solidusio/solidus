# frozen_string_literal: true

require 'spec_helper'

describe "Orders Listing", type: :feature, js: true do
  stub_authorization!

  let!(:promotion) { create(:promotion_with_item_adjustment, code: "vnskseiw") }
  let(:promotion_code) { promotion.codes.first }

  before(:each) do
    allow_any_instance_of(Spree::OrderInventory).to receive(:add_to_shipment)
    @order1 = create(:order_with_line_items, created_at: 1.day.from_now, completed_at: 1.day.from_now, number: "R100")
    @order2 = create(:order, created_at: 1.day.ago, completed_at: 1.day.ago, number: "R200")
    visit spree.admin_orders_path
  end

  it 'displays the new order button' do
    expect(page).to have_link('New Order')
  end

  context 'without create permission' do
    custom_authorization! do |_user|
      can :manage, Spree::Order
      cannot :create, Spree::Order
    end

    it 'does not display the new order button' do
      expect(page).to_not have_link('New Order')
    end
  end

  context "listing orders" do
    it "should list existing orders" do
      within_row(1) do
        expect(column_text(2)).to eq "R100"
        expect(column_text(3)).to eq "Cart"
      end

      within_row(2) do
        expect(column_text(2)).to eq "R200"
      end
    end

    it "should be able to sort the orders listing" do
      # default is completed_at desc
      within_row(1) { expect(page).to have_content("R100") }
      within_row(2) { expect(page).to have_content("R200") }

      click_link "Completed at", exact: false

      # Completed at desc
      within_row(1) { expect(page).to have_content("R200") }
      within_row(2) { expect(page).to have_content("R100") }

      within('table#listing_orders thead') { click_link "Number" }

      # number asc
      within_row(1) { expect(page).to have_content("R100") }
      within_row(2) { expect(page).to have_content("R200") }
    end
  end

  context "searching orders" do
    context "when there are multiple stores" do
      let(:stores) { FactoryBot.create_pair(:store) }

      before do
        stores.each do |store|
          FactoryBot.create(:completed_order_with_totals, number: "R#{store.id}999", store: store)
        end
      end

      it "can find the orders belonging to a specific store" do
        main_store, other_store = stores

        click_on "Filter Results"
        select main_store.name, from: I18n.t('spree.store')
        click_on "Filter Results"

        within_row(1) do
          expect(page).to have_content("R#{main_store.id}999")
        end

        # Ensure that the other order doesn't show up
        within("table#listing_orders") { expect(page).not_to have_content("R#{other_store.id}999") }
      end
    end

    context "when there's a single store" do
      it "should be able to search orders" do
        click_on "Filter Results"
        fill_in "q_number_start", with: "R200"
        click_on 'Filter Results'
        within_row(1) do
          expect(page).to have_content("R200")
        end

        # Ensure that the other order doesn't show up
        within("table#listing_orders") { expect(page).not_to have_content("R100") }
      end

      it "should be able to filter on variant_id" do
        click_on "Filter Results"
        select2_search @order1.products.first.sku, from: I18n.t('spree.variant')
        click_on 'Filter Results'

        within_row(1) do
          expect(page).to have_content(@order1.number)
        end

        expect(page).not_to have_content(@order2.number)
      end

      context "when pagination is really short" do
        before do
          stub_spree_preferences(orders_per_page: 1)
        end

        # Regression test for https://github.com/spree/spree/issues/4004
        it "should be able to go from page to page for incomplete orders" do
          10.times { Spree::Order.create email: "incomplete@example.com" }
          click_on "Filter Results"
          uncheck "q_completed_at_not_null"
          click_on 'Filter Results'
          within(".pagination", match: :first) do
            click_link "2"
          end
          expect(page).to have_content("incomplete@example.com")
          click_on "Filter Results"
          expect(find("#q_completed_at_not_null")).not_to be_checked
        end
      end

      it "should be able to search orders using only completed at input" do
        click_on "Filter Results"
        fill_in "q_created_at_gt", with: Date.current

        click_on 'Filter Results'
        within_row(1) { expect(page).to have_content("R100") }

        # Ensure that the other order doesn't show up
        within("table#listing_orders") { expect(page).not_to have_content("R200") }
      end

      context "filter on promotions" do
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

      context "when toggling the completed orders checkbox" do
        before do
          create(:order, number: 'R300', completed_at: nil, state: 'cart')
        end

        it "shows both complete and incomplete orders" do
          check "q_completed_at_not_null"
          click_on "Filter Results"

          expect(page).to have_content("R200")
          expect(page).to_not have_content("R300")

          uncheck "q_completed_at_not_null"
          click_on 'Filter Results'

          expect(page).to have_content("R200")
          expect(page).to have_content("R300")
        end
      end
    end
  end
end
