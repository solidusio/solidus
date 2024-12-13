# frozen_string_literal: true

require "spec_helper"

describe "StoreCredits", :js, type: :feature do
  let(:admin) { create(:admin_user, email: "admin@example.com") }

  before do
    sign_in admin
  end

  context "when a user has no store credits" do
    before do
      create(:user, email: "customer@example.com")
      visit "/admin/users"
      find_row("customer@example.com").click
      click_on "Store Credit"
    end

    it "shows the store credits page" do
      expect(page).to have_content("Users / customer@example.com / Store Credit")
      expect(page).to have_content("Lifetime Stats")
      expect(page).to have_content("Store Credit")
      expect(page).to be_axe_clean
    end

    it "shows the appropriate content" do
      expect(page).to have_content("No Store Credits found.")
    end
  end

  context "when a user has store credits" do
    let!(:store_credit) { create(:store_credit, amount: 199.00, currency: "USD") }
    let!(:store_credit_reason) { create(:store_credit_reason, name: "credit given in error") }

    before do
      store_credit.user.update(email: "customer@example.com")

      visit "/admin/users"
      find_row("customer@example.com").click
      click_on "Store Credit"
    end

    it "shows the store credits page" do
      expect(page).to have_content("Users / customer@example.com / Store Credit")
      expect(page).to have_content("Lifetime Stats")
      expect(page).to have_content("Store Credit")
      expect(page).to be_axe_clean
    end

    it "lists the user's store credit" do
      expect(page).to have_content("Current balance: $199.00")
      expect(page).to have_content("Credited")
      expect(page).to have_content("Authorized")
      expect(page).to have_content("Used")
      expect(page).to have_content("Type")
      expect(page).to have_content("Created by")
      expect(page).to have_content("Issued on")
      expect(page).to have_content("Invalidated")
      expect(page).not_to have_content("No Store Credits found.")
    end

    context "when clicking through to a single store credit" do
      let!(:store_credit_reason) { create(:store_credit_reason, name: "credit given in error") }

      before do
        stub_authorization!(admin)
        find_row("$199.00").click
      end

      it "shows individual store credit details" do
        expect(page).to have_content("Users / customer@example.com / Store Credit / $199.00")
        expect(page).to have_content("Store Credit History")
        expect(page).to have_content("Action")
        expect(page).to have_content("Added")
      end

      context "when editing the store credit amount" do
        context "with invalid amount" do
          it "shows the appropriate error message" do
            click_on "Edit Amount"
            expect(page).to have_selector("dialog", wait: 5)
            expect(page).to have_content("Edit Store Credit Amount")

            within("dialog") do
              fill_in "Amount", with: ""
              click_on "Update Store Credit"
              expect(page).to have_content("must be greater than 0")
              click_on "Cancel"
            end
          end
        end

        context "without a valid reason" do
          it "shows the appropriate error message" do
            click_on "Edit Amount"
            expect(page).to have_selector("dialog", wait: 5)
            expect(page).to have_content("Edit Store Credit Amount")

            within("dialog") do
              fill_in "Amount", with: "100"
              click_on "Update Store Credit"
              expect(page).to have_content("Store Credit reason must be provided")
              click_on "Cancel"
            end
          end
        end

        context "with valid params" do
          it "allows editing of the store credit amount" do
            click_on "Edit Amount"
            expect(page).to have_selector("dialog", wait: 5)
            expect(page).to have_content("Edit Store Credit Amount")

            within("dialog") do
              fill_in "Amount", with: "666"
              select "credit given in error", from: "store_credit[store_credit_reason_id]"
              click_on "Update Store Credit"
            end

            expect(page).to have_content("Users / customer@example.com / Store Credit / $666.00")
            expect(page).to have_content("Adjustment")
            expect(page).to have_content("credit given in error")
          end
        end
      end

      context "when invalidating" do
        context "without a valid reason" do
          it "shows the appropriate error message" do
            click_on "Invalidate"
            expect(page).to have_selector("dialog", wait: 5)
            expect(page).to have_content("Invalidate Store Credit")

            within("dialog") do
              click_on "Invalidate"
              expect(page).to have_content("Store Credit reason must be provided")
              click_on "Cancel"
            end
          end
        end

        context "with a valid reason" do
          it "invalidates the store credit" do
            click_on "Invalidate"
            expect(page).to have_selector("dialog", wait: 5)
            expect(page).to have_content("Invalidate Store Credit")

            within("dialog") do
              select "credit given in error", from: "store_credit[store_credit_reason_id]"
              click_on "Invalidate"
            end

            expect(page).to have_content("Store credit was successfully invalidated.")
            expect(page).to have_content("Invalidated")
            expect(page).to have_content("credit given in error")
            expect(page).not_to have_content("Edit Amount")
          end
        end
      end

      context "when editing the store credit memo" do
        it "allows editing of the store credit memo" do
          click_on "Edit Memo"
          expect(page).to have_selector("dialog", wait: 5)
          expect(page).to have_content("Edit Store Credit Memo")

          within("dialog") do
            fill_in "Memo", with: "dogtown"
            click_on "Update Store Credit"
          end

          expect(page).to have_content("Store credit was successfully updated.")
          expect(page).to have_content("dogtown")
        end
      end
    end
  end
end
