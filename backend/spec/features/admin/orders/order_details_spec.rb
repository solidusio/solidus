# coding: utf-8
require 'spec_helper'

describe "Order Details", type: :feature, js: true do
  let!(:stock_location) { create(:stock_location_with_items) }
  let!(:product) { create(:product, :name => 'solidus t-shirt', :price => 20.00) }
  let!(:tote) { create(:product, :name => "Tote", :price => 15.00) }
  let(:order) { create(:order, :state => 'complete', :completed_at => "2011-02-01 12:36:15", :number => "R100") }
  let(:state) { create(:state) }
  #let(:shipment) { create(:shipment, :order => order, :stock_location => stock_location) }
  let!(:shipping_method) { create(:shipping_method, :name => "Default") }

  before do
    order.shipments.create(stock_location_id: stock_location.id)
    order.contents.add(product.master, 2)
  end

  context 'as Admin' do
    stub_authorization!


    context "cart edit page" do
      before do
        product.master.stock_items.first.update_column(:count_on_hand, 100)
        visit solidus.cart_admin_order_path(order)
      end


      it "should allow me to edit order details" do
        expect(page).to have_content("solidus t-shirt")
        expect(page).to have_content("$40.00")

        within_row(1) do
          click_icon :edit
          fill_in "quantity", :with => "1"
        end
        click_icon :ok

        within("#order_total") do
          expect(page).to have_content("$20.00")
        end
      end

      it "can add an item to a shipment" do
        select2_search "solidus t-shirt", :from => Solidus.t(:name_or_sku)
        within("table.stock-levels") do
          fill_in "quantity_0", :with => 2
        end

        click_icon :plus

        within("#order_total") do
          expect(page).to have_content("$80.00")
        end
      end

      it "can remove an item from a shipment" do
        expect(page).to have_content("solidus t-shirt")

        within_row(1) do
          accept_alert do
            click_icon :trash
          end
        end

        expect(page).to have_content("YOUR ORDER IS EMPTY") # wait for page refresh
        expect(page).not_to have_content("solidus t-shirt")
      end

      # Regression test for #3862
      it "can cancel removing an item from a shipment" do
        expect(page).to have_content("solidus t-shirt")

        within_row(1) do
          # Click "cancel" on confirmation dialog
          dismiss_alert do
            click_icon :trash
          end
        end

        expect(page).to have_content("solidus t-shirt")
      end

      it "can add tracking information" do
        visit solidus.edit_admin_order_path(order)

        within(".show-tracking") do
          click_icon :edit
        end
        fill_in "tracking", :with => "FOOBAR"
        click_icon :check

        expect(page).not_to have_css("input[name=tracking]")
        expect(page).to have_content("Tracking: FOOBAR")
      end

      it "can change the shipping method" do
        order = create(:completed_order_with_totals)
        visit solidus.edit_admin_order_path(order)
        within("table.index tr.show-method") do
          click_icon :edit
        end
        select2 "Default", :from => "Shipping Method"
        click_icon :check

        expect(page).not_to have_css('#selected_shipping_rate_id')
        expect(page).to have_content("Default")
      end

      it "will show the variant sku" do
        order = create(:completed_order_with_totals)
        visit solidus.edit_admin_order_path(order)
        sku = order.line_items.first.variant.sku
        expect(page).to have_content("SKU: #{sku}")
      end

      context "with special_instructions present" do
        let(:order) { create(:order, :state => 'complete', :completed_at => "2011-02-01 12:36:15", :number => "R100", :special_instructions => "Very special instructions here") }
        it "will show the special_instructions" do
          visit solidus.edit_admin_order_path(order)
          expect(page).to have_content("Very special instructions here")
        end
      end

      context "variant doesn't track inventory" do
        before do
          tote.master.update_column :track_inventory, false
          # make sure there's no stock level for any item
          tote.master.stock_items.update_all count_on_hand: 0, backorderable: false
        end

        it "adds variant to order just fine" do
          select2_search tote.name, :from => Solidus.t(:name_or_sku)
          within("table.stock-levels") do
            fill_in "variant_quantity", :with => 1
          end

          click_icon :plus

          within(".line-items") do
            expect(page).to have_content(tote.name)
          end
        end
      end

      context "variant out of stock and not backorderable" do
        before do
          product.master.stock_items.first.update_column(:backorderable, false)
          product.master.stock_items.first.update_column(:count_on_hand, 0)
        end

        it "doesn't display the out of stock variant in the search results" do
          select2_search_without_selection product.name, from: ".variant_autocomplete"

          expect(page).to have_selector('.select2-no-results')
          within(".select2-no-results") do
            expect(page).to have_content("NO MATCHES FOUND")
          end
        end
      end
    end


    context 'Shipment edit page' do
      let!(:stock_location2) { create(:stock_location_with_items, name: 'Clarksville') }

      before do
        product.master.stock_items.first.update_column(:backorderable, true)
        product.master.stock_items.first.update_column(:count_on_hand, 100)
        product.master.stock_items.last.update_column(:count_on_hand, 100)
      end

      context 'splitting to location' do
        before { visit solidus.edit_admin_order_path(order) }
        # can not properly implement until poltergeist supports checking alert text
        # see https://github.com/teampoltergeist/poltergeist/pull/516
        it 'should warn you if you have not selected a location or shipment'

        context 'there is enough stock at the other location' do
          it 'should allow me to make a split' do
            expect(order.shipments.count).to eq(1)
            expect(order.shipments.first.inventory_units_for(product.master).count).to eq(2)

            within_row(1) { click_icon 'arrows-h' }
            targetted_select2 stock_location2.name, from: '#s2id_item_stock_location'
            click_icon :ok

            expect(page).to have_css('.shipment', count: 2)

            expect(order.shipments.count).to eq(2)
            expect(order.shipments.last.backordered?).to eq(false)
            expect(order.shipments.first.inventory_units_for(product.master).count).to eq(1)
            expect(order.shipments.last.inventory_units_for(product.master).count).to eq(1)
          end

          it 'should allow me to make a transfer via splitting off all stock' do
            expect(order.shipments.first.stock_location.id).to eq(stock_location.id)

            within_row(1) { click_icon 'arrows-h' }
            targetted_select2 stock_location2.name, from: '#s2id_item_stock_location'
            fill_in 'item_quantity', with: 2
            click_icon :ok

            expect(page).to have_content("PENDING PACKAGE FROM 'CLARKSVILLE'")

            expect(order.shipments.count).to eq(1)
            expect(order.shipments.last.backordered?).to eq(false)
            expect(order.shipments.first.inventory_units_for(product.master).count).to eq(2)
            expect(order.shipments.first.stock_location.id).to eq(stock_location2.id)
          end

          it 'should allow me to split more than I have if available there' do
            expect(order.shipments.first.stock_location.id).to eq(stock_location.id)

            within_row(1) { click_icon 'arrows-h' }
            targetted_select2 stock_location2.name, from: '#s2id_item_stock_location'
            fill_in 'item_quantity', with: 5
            click_icon :ok

            expect(page).to have_content("PENDING PACKAGE FROM 'CLARKSVILLE'")

            expect(order.shipments.count).to eq(1)
            expect(order.shipments.last.backordered?).to eq(false)
            expect(order.shipments.first.inventory_units_for(product.master).count).to eq(5)
            expect(order.shipments.first.stock_location.id).to eq(stock_location2.id)
          end

          it 'should not split anything if the input quantity is garbage' do
            expect(order.shipments.first.stock_location.id).to eq(stock_location.id)

            within_row(1) { click_icon 'arrows-h' }
            targetted_select2 stock_location2.name, from: '#s2id_item_stock_location'
            fill_in 'item_quantity', with: 'ff'
            click_icon :ok

            wait_for_ajax

            expect(order.shipments.count).to eq(1)
            expect(order.shipments.first.inventory_units_for(product.master).count).to eq(2)
            expect(order.shipments.first.stock_location.id).to eq(stock_location.id)
          end

          it 'should not allow less than or equal to zero qty' do
            expect(order.shipments.first.stock_location.id).to eq(stock_location.id)

            within_row(1) { click_icon 'arrows-h' }
            targetted_select2 stock_location2.name, from: '#s2id_item_stock_location'
            fill_in 'item_quantity', with: 0
            click_icon :ok

            wait_for_ajax

            expect(order.shipments.count).to eq(1)
            expect(order.shipments.first.inventory_units_for(product.master).count).to eq(2)
            expect(order.shipments.first.stock_location.id).to eq(stock_location.id)


            fill_in 'item_quantity', with: -1
            click_icon :ok

            wait_for_ajax

            expect(order.shipments.count).to eq(1)
            expect(order.shipments.first.inventory_units_for(product.master).count).to eq(2)
            expect(order.shipments.first.stock_location.id).to eq(stock_location.id)
          end

          context 'A shipment has shipped' do

            it 'should not show or let me back to the cart page, nor show the shipment edit buttons' do
              order = create(:order, :state => 'payment', :number => "R100")
              order.shipments.create!(stock_location_id: stock_location.id, state: 'shipped')

              visit solidus.cart_admin_order_path(order)

              expect(page.current_path).to eq(solidus.edit_admin_order_path(order))
              expect(page).not_to have_text 'Cart'
              expect(page).not_to have_selector('.fa-arrows-h')
              expect(page).not_to have_selector('.fa-trash')
            end

          end
        end

        context 'there is not enough stock at the other location' do
          context 'and it cannot backorder' do
            it 'should not allow me to split stock' do
              product.master.stock_items.last.update_column(:backorderable, false)
              product.master.stock_items.last.update_column(:count_on_hand, 0)

              within_row(1) { click_icon 'arrows-h' }
              targetted_select2 stock_location2.name, from: '#s2id_item_stock_location'
              fill_in 'item_quantity', with: 2
              click_icon :ok

              wait_for_ajax

              expect(order.shipments.count).to eq(1)
              expect(order.shipments.first.inventory_units_for(product.master).count).to eq(2)
              expect(order.shipments.first.stock_location.id).to eq(stock_location.id)
            end

          end

          context 'but it can backorder' do
            it 'should allow me to split and backorder the stock' do
              product.master.stock_items.last.update_column(:count_on_hand, 0)
              product.master.stock_items.last.update_column(:backorderable, true)

              within_row(1) { click_icon 'arrows-h' }
              targetted_select2 stock_location2.name, from: '#s2id_item_stock_location'
              fill_in 'item_quantity', with: 2
              click_icon :ok

              expect(page).to have_content("PENDING PACKAGE FROM 'CLARKSVILLE'")

              expect(order.shipments.count).to eq(1)
              expect(order.shipments.first.inventory_units_for(product.master).count).to eq(2)
              expect(order.shipments.first.stock_location.id).to eq(stock_location2.id)
            end
          end
        end

        context 'multiple items in cart' do
          it 'should have no problem splitting if multiple items are in the from shipment' do
            order.contents.add(create(:variant), 2)
            expect(order.shipments.count).to eq(1)
            expect(order.shipments.first.manifest.count).to eq(2)

            within_row(1) { click_icon 'arrows-h' }
            targetted_select2 stock_location2.name, from: '#s2id_item_stock_location'
            click_icon :ok

            expect(page).to have_css('.shipment', count: 2)

            expect(order.shipments.count).to eq(2)
            expect(order.shipments.last.backordered?).to eq(false)
            expect(order.shipments.first.inventory_units_for(product.master).count).to eq(1)
            expect(order.shipments.last.inventory_units_for(product.master).count).to eq(1)
          end
        end
      end


      context 'splitting to shipment' do
        before do
          @shipment2 = order.shipments.create(stock_location_id: stock_location2.id)
          visit solidus.edit_admin_order_path(order)
        end

        it 'should delete the old shipment if enough are split off' do
          expect(order.shipments.count).to eq(2)

          within_row(1) { click_icon 'arrows-h' }
          targetted_select2 @shipment2.number, from: '#s2id_item_stock_location'
          fill_in 'item_quantity', with: 2
          click_icon :ok

          wait_for_ajax

          expect(order.shipments.count).to eq(1)
          expect(order.shipments.last.inventory_units_for(product.master).count).to eq(2)
        end

        context 'receiving shipment can not backorder' do
          before { product.master.stock_items.last.update_column(:backorderable, false) }

          it 'should not allow a split if the receiving shipment qty plus the incoming is greater than the count_on_hand' do
            expect(order.shipments.count).to eq(2)

            within_row(1) { click_icon 'arrows-h' }
            targetted_select2 @shipment2.number, from: '#s2id_item_stock_location'
            fill_in 'item_quantity', with: 1
            click_icon :ok

            within(all('.stock-contents', count: 2).first) do
              within_row(1) { click_icon 'arrows-h' }
              targetted_select2 @shipment2.number, from: '#s2id_item_stock_location'
              fill_in 'item_quantity', with: 200
              click_icon :ok
            end

            wait_for_ajax

            expect(order.shipments.count).to eq(2)
            expect(order.shipments.first.inventory_units_for(product.master).count).to eq(1)
            expect(order.shipments.last.inventory_units_for(product.master).count).to eq(1)
          end

          it 'should not allow a shipment to split stock to itself' do
            within_row(1) { click_icon 'arrows-h' }
            targetted_select2 order.shipments.first.number, from: '#s2id_item_stock_location'
            fill_in 'item_quantity', with: 1
            click_icon :ok

            wait_for_ajax

            expect(order.shipments.count).to eq(2)
            expect(order.shipments.first.inventory_units_for(product.master).count).to eq(2)
          end

          it 'should split fine if more than one line_item is in the receiving shipment' do
            variant2 = create(:variant)
            order.contents.add(variant2, 2, shipment: @shipment2)

            within_row(1) { click_icon 'arrows-h' }
            targetted_select2 @shipment2.number, from: '#s2id_item_stock_location'
            fill_in 'item_quantity', with: 1
            click_icon :ok

            wait_for_ajax

            expect(order.shipments.count).to eq(2)
            expect(order.shipments.first.inventory_units_for(product.master).count).to eq 1
            expect(order.shipments.last.inventory_units_for(product.master).count).to eq 1
            expect(order.shipments.first.inventory_units_for(variant2).count).to eq 0
            expect(order.shipments.last.inventory_units_for(variant2).count).to eq 2
          end
        end

        context 'receiving shipment can backorder' do
          it 'should add more to the backorder' do
            product.master.stock_items.last.update_column(:backorderable, true)
            product.master.stock_items.last.update_column(:count_on_hand, 0)
            expect(@shipment2.reload.backordered?).to eq(false)

            within_row(1) { click_icon 'arrows-h' }
            targetted_select2 @shipment2.number, from: '#s2id_item_stock_location'
            fill_in 'item_quantity', with: 1
            click_icon :ok

            expect(page).to have_content("1 x backordered")

            within('.stock-contents', text: "1 x on hand") do
              within_row(1) { click_icon 'arrows-h' }
              targetted_select2 @shipment2.number, from: '#s2id_item_stock_location'
              fill_in 'item_quantity', with: 1
              click_icon :ok
            end

            # Empty shipment should be removed
            expect(page).to have_css('.stock-contents', count: 1)
            expect(page).to have_content("2 x backordered")
          end
        end
      end
    end
  end

  context 'with only read permissions' do
    before do
      allow_any_instance_of(Solidus::Admin::BaseController).to receive(:solidus_current_user).and_return(nil)
    end

    custom_authorization! do |user|
      can [:admin, :index, :read, :edit], Solidus::Order
    end
    it "should not display forbidden links" do
      visit solidus.edit_admin_order_path(order)

      expect(page).not_to have_button('cancel')
      expect(page).not_to have_button('Resend')

      # Order Tabs
      expect(page).not_to have_link('Adjustments')
      expect(page).not_to have_link('Payments')
      expect(page).not_to have_link('Return Authorizations')

      # Order item actions
      expect(page).not_to have_css('.delete-item')
      expect(page).not_to have_css('.split-item')
      expect(page).not_to have_css('.edit-item')
      expect(page).not_to have_css('.edit-tracking')

      expect(page).not_to have_css('#add-line-item')
    end
  end

  context 'as Fakedispatch' do
    custom_authorization! do |user|
      # allow dispatch to :admin, :index, and :edit on Solidus::Order
      can [:admin, :edit, :index, :read], Solidus::Order
      # allow dispatch to :index, :show, :create and :update shipments on the admin
      can [:admin, :manage, :read, :ship], Solidus::Shipment
    end

    before do
      allow(Solidus.user_class).to receive(:find_by).
                                   with(hash_including(:solidus_api_key)).
                                   and_return(Solidus.user_class.new)
    end

    it 'should not display order tabs or edit buttons without ability' do
      visit solidus.edit_admin_order_path(order)

      # Order Form
      expect(page).not_to have_css('.edit-item')
      # Order Tabs
      expect(page).not_to have_link('Adjustments')
      expect(page).not_to have_link('Payments')
      expect(page).not_to have_link('Return Authorizations')
    end

    it "can change the shipping method" do
      order = create(:completed_order_with_totals)
      visit solidus.edit_admin_order_path(order)
      within("table.index tr.show-method") do
        click_icon :edit
      end
      select2 "Default", :from => "Shipping Method"
      click_icon :check

      expect(page).not_to have_css('#selected_shipping_rate_id')
      expect(page).to have_content("Default")
    end

    it 'can ship' do
      order = create(:order_ready_to_ship)
      order.refresh_shipment_rates
      visit solidus.edit_admin_order_path(order)

      find(".ship-shipment-button").click
      wait_for_ajax

      within '.carton-state' do
        expect(page).to have_content('SHIPPED')
      end
    end
  end
end
