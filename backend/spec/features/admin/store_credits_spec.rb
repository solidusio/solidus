require 'spec_helper'

describe "Store credits admin" do
  stub_authorization!
  let!(:admin_user)   { create(:admin_user) }
  let!(:store_credit) { create(:store_credit) }
  let(:user)          { store_credit.user }

  before do
    allow(Spree.user_class).to receive(:find_by).
      with(hash_including(:id)).
      and_return(store_credit.user)
  end

  describe "visiting the store credits page" do
    before do
      visit spree.admin_path
      click_link "Users"
    end

    it "should be on the store credits page" do
      click_link store_credit.user.email
      click_link "Store Credit"
      expect(page.current_path).to eq spree.admin_user_store_credits_path(store_credit.user)

      store_credit_table = page.find(".twelve.columns > table")
      expect(store_credit_table).to have_css('tr', count: 1)
      expect(store_credit_table).to have_content(Spree::Money.new(store_credit.amount).to_s)
      expect(store_credit_table).to have_content(Spree::Money.new(store_credit.amount_used).to_s)
      expect(store_credit_table).to have_content(store_credit.category_name)
      expect(store_credit_table).to have_content(store_credit.created_by_email)
    end
  end

  describe "creating store credit" do
    before do
      visit spree.admin_path
      click_link "Users"
      click_link store_credit.user.email
      click_link "Store Credit"
      allow_any_instance_of(Spree::Admin::StoreCreditsController).to receive_messages(try_spree_current_user: admin_user)
    end

    it "should create store credit and associate it with the user" do
      click_link "Add store credit"
      page.fill_in "store_credit_amount", with: "102.00"
      select "Exchange", from: "store_credit_category_id"
      click_button "Create"

      expect(page.current_path).to eq spree.admin_user_store_credits_path(store_credit.user)
      store_credit_table = page.find(".twelve.columns > table")
      expect(store_credit_table).to have_css('tr', count: 2)
      expect(Spree::StoreCredit.count).to eq 2
    end
  end

  describe "updating store credit" do
    let(:updated_amount) { "99.0" }
    let!(:update_reason) { create(:store_credit_update_reason) }

    before do
      visit spree.admin_path
      click_link "Users"
      click_link store_credit.user.email
      click_link "Store Credit"
      allow_any_instance_of(Spree::Admin::StoreCreditsController).to receive_messages(try_spree_current_user: admin_user)
    end

    it "updates the store credit's amount" do
      page.find(".twelve.columns > table td.actions a.fa-edit").click
      expect(page).to have_content 'Store credit history'
      click_link "Change amount"
      expect(page).to have_content 'Editing store credit amount'
      page.fill_in 'store_credit_amount', with: updated_amount
      page.select update_reason.name, from: 'update_reason_id'
      click_button "Update"
      expect(page.find('#sc-detail-table')).to have_content "$99.00"
      expect(store_credit.reload.amount.to_f).to eq updated_amount.to_f
    end
  end
end
