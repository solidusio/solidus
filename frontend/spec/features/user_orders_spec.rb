# frozen_string_literal: true

require 'spec_helper'

describe "User orders page", type: :feature do
  before do
    allow_any_instance_of(Spree::UsersController).to receive_messages(try_spree_current_user: user)
  end

  context 'when the user is not authenticated' do
    let(:user) { nil }

    it 'fails authentication' do
      visit spree.account_path
      expect(page).to have_content 'Authorization Failure'
    end
  end

  context 'when the user is authenticated' do
    let(:user) { create :user }

    let!(:cart_order) { create :order, user: user }
    let!(:complete_order) { create :completed_order_with_totals, user: user }

    it 'lists user complete orders' do
      visit spree.account_path
      expect(page).to have_content 'My Account'
      expect(page).to have_content user.email
      expect(page).to have_content complete_order.number
      expect(page).not_to have_content cart_order.number
    end
  end
end
