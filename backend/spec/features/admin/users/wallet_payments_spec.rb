# frozen_string_literal: true

require 'spec_helper'

describe "User's Wallet Payments", type: :feature do
  stub_authorization!
  let!(:user) { create(:user_with_addresses, email: 'a@example.com') }

  before do
    visit spree.admin_path
    click_link 'Users'
    click_link user.email
  end

  context 'without any payment source' do
    it 'shows no wallets payments' do
      click_link "Wallet"
      expect(page).to have_content('No Wallet Payments found')
    end
  end

  context 'when has payment sources saved in the wallet' do
    let!(:first_order) { create(:completed_order_with_totals, user: user) }
    let!(:first_credit_card) { create(:credit_card, user: user, number: '4111111111111111', name: 'Peter Parker') }
    let!(:first_order_payment) { create(:payment, source: first_credit_card, order: first_order, state: 'pending') }

    let!(:second_order) { create(:completed_order_with_totals, user: user) }
    let!(:second_order_credit_card) { create(:credit_card, user: user, number: '5500000000000004', name: 'Auntie May') }
    let!(:second_order_payment) { create(:payment, source: second_order_credit_card, order: second_order, state: 'pending') }

    before do
      # This is done in an after trasition via state machine that is not
      # executed creating orders with the factory above.
      first_order.add_payment_sources_to_wallet
      second_order.add_payment_sources_to_wallet

      click_link "Wallet"
    end

    it 'lists existing payment sources' do
      expect(page).to have_content('XXXX-XXXX-XXXX-1111 - Peter Parker')
      expect(page).to have_content('XXXX-XXXX-XXXX-0004 - Auntie May')
    end

    it 'allows to remove payment sources', js: true do
      within 'tr', text: 'XXXX-XXXX-XXXX-1111 - Peter Parker' do
        accept_alert do
          click_icon :trash
        end
      end
      expect(page).to have_content 'successfully removed'
      expect(page).not_to have_content('XXXX-XXXX-XXXX-1111 - Peter Parker')
    end

    it 'allows to mark payment sources as default', js: true do
      within 'tr', text: 'XXXX-XXXX-XXXX-1111 - Peter Parker' do
        click_link 'Make Default'
      end

      within 'tr', text: 'XXXX-XXXX-XXXX-1111 - Peter Parker' do
        within '.pill' do
          expect(page).to have_content('Default')
        end
      end
    end
  end
end
