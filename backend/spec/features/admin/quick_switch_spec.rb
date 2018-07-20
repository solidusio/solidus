# frozen_string_literal: true

require 'spec_helper'

describe "Quick Switch", type: :feature, js: true do
  context 'as admin user' do
    stub_authorization!

    context "visiting any page" do
      let(:initial_page) { spree.admin_orders_path }
      before(:each) { visit initial_page }

      it 'can open the quick switch' do
        open_quick_switch
        expect(page).to have_css("#quick-switch", visible: true)
      end

      context 'searching for a variant' do
        before { open_quick_switch }

        context 'if it exists' do
          let!(:variant) { create(:variant) }

          it 'redirects to that variant\'s product page' do
            fill_in('quick_switch_query', with: "v #{variant.sku}").native.send_keys(:return)
            expect(page).to have_current_path spree.edit_admin_product_variant_path(variant.product, variant)
          end
        end

        context 'if it does not exist' do
          it 'prints an error message' do
            fill_in('quick_switch_query', with: "v SKU-NOT-PRESENT").native.send_keys(:return)
            expect(page).to have_current_path initial_page
            expect(page).to have_content 'Unable to find a variant with a SKU matching SKU-NOT-PRESENT.'
          end
        end
      end

      context 'searching for a user' do
        before { open_quick_switch }

        context 'if it exists' do
          let!(:user) { create(:user) }

          it 'redirects to that user page' do
            fill_in('quick_switch_query', with: "u #{user.email}").native.send_keys(:return)
            expect(page).to have_current_path spree.edit_admin_user_path(user)
          end
        end

        context 'if it does not exist' do
          it 'prints an error message' do
            fill_in('quick_switch_query', with: "u user@404.com").native.send_keys(:return)
            expect(page).to have_current_path initial_page
            expect(page).to have_content 'Unable to find a user with an email matching user@404.com.'
          end
        end
      end

      context 'searching for an order' do
        before { open_quick_switch }

        context 'if it exists' do
          let!(:order) { create(:order) }

          it 'redirects to that order page' do
            fill_in('quick_switch_query', with: "o #{order.number}").native.send_keys(:return)
            expect(page).to have_current_path spree.edit_admin_order_path(order)
          end
        end

        context 'if it does not exist' do
          it 'prints an error message' do
            fill_in('quick_switch_query', with: "o ORDER-NOT-PRESENT").native.send_keys(:return)
            expect(page).to have_current_path initial_page
            expect(page).to have_content 'Order ORDER-NOT-PRESENT could not be found.'
          end
        end
      end

      context 'searching for a shipment' do
        before { open_quick_switch }

        context 'if it exists' do
          let!(:shipment) { create(:shipment) }

          it 'redirects to that shipment\'s order page' do
            fill_in('quick_switch_query', with: "s #{shipment.number}").native.send_keys(:return)
            expect(page).to have_current_path spree.edit_admin_order_path(shipment.order)
          end
        end

        context 'if it does not exist' do
          it 'prints an error message' do
            fill_in('quick_switch_query', with: "s SHIPMENT-NOT-PRESENT").native.send_keys(:return)
            expect(page).to have_current_path initial_page
            expect(page).to have_content 'Shipment SHIPMENT-NOT-PRESENT could not be found.'
          end
        end
      end
    end
  end

  private

  def open_quick_switch
    keypress_script = "var e = $.Event( 'keypress', { key: '@' } ); $('body').trigger(e);"
    page.driver.browser.execute_script(keypress_script)
  end
end
