require 'spec_helper'

describe Spree::StoreCreditLedgerEntry do
  let(:currency) { "TEST" }
  let(:store_credit) { build(:store_credit, store_credit_attrs) }
  let(:store_credit_attrs) { {} }

  context 'store credits events' do
    describe "callbacks" do
      context "creating ledger entry" do
        let(:store_credit_attrs) { { amount: 250 } }

        it "on create" do
          expect{ store_credit.save }.to change { store_credit.store_credit_ledger_entries.count }.by 1
        end

        it "will have a balance equal to the amount" do
          store_credit.save
          expect(store_credit.liability_balance).to eql 250
        end
      end
    end

    describe "#authorize" do
      context "amount is valid" do
        let(:authorization_amount)       { 1.0 }
        let(:added_authorization_amount) { 3.0 }
        let(:originator) { nil }

        context "amount has not been authorized yet" do
          before { store_credit.update_attributes(amount_authorized: authorization_amount) }

          it "will store a 'pending' ledger entry" do
            expect {
              store_credit.authorize(added_authorization_amount, store_credit.currency)
            }.to change{ store_credit.store_credit_ledger_entries.pending.count }
          end

          it "will set the expected balance" do
            store_credit.authorize(added_authorization_amount, store_credit.currency)
            expect(store_credit.balance).to eql store_credit.amount - added_authorization_amount
          end

          it "will not change the liability balance" do
            expect {
              store_credit.authorize(added_authorization_amount, store_credit.currency)
            }.to_not change{ store_credit.liability_balance }
          end

          context "originator is present" do
            let(:originator) { create(:user) } # won't actually be a user. just giving it a valid model here

            subject { store_credit.authorize(added_authorization_amount, store_credit.currency, action_originator: originator) }

            it "records the originator on the ledger entry" do
              expect { subject }.to change { store_credit.store_credit_ledger_entries.pending.count }.by(1)
              expect(store_credit.store_credit_ledger_entries.pending.last.originator).to eq originator
            end
          end
        end
      end
    end

    describe "#capture" do
      let(:authorized_amount) { 10.00 }
      let(:auth_code)         { "23-SC-20140602164814476128" }

      before do
        @original_authed_amount = store_credit.amount_authorized
        @auth_code = store_credit.authorize(authorized_amount, store_credit.currency)
      end

      context "insufficient funds" do
        subject { store_credit.capture(authorized_amount * 2, @auth_code, store_credit.currency) }

        it "does not add an entry to the ledger" do
          expect { subject }.to_not change { store_credit.store_credit_ledger_entries.count }
        end
      end

      context "currency mismatch" do
        subject { store_credit.capture(authorized_amount, @auth_code, "EUR") }

        it "does not add an entry to the ledger" do
          expect { subject }.to_not change { store_credit.store_credit_ledger_entries.count }
        end
      end

      context "valid capture" do
        let(:remaining_authorized_amount) { 1 }
        let(:originator) { nil }

        subject { store_credit.capture(authorized_amount - remaining_authorized_amount, @auth_code, store_credit.currency, action_originator: originator) }

        it "adds an entry to the ledger for both liability and pending" do
          expect { subject }.to change { store_credit.store_credit_ledger_entries.count }.by(2)
        end

        it "will lower the liability balance with the amount captured" do
          captured_amount = authorized_amount - remaining_authorized_amount
          expect { subject }.to change { store_credit.liability_balance }.by(-1 * captured_amount)
        end

        it "will not change the balance for the amount useable when the authorized amount is captured" do
          expect { subject }.to_not change { store_credit.balance }
        end

        context "originator is present" do
          let(:originator) { create(:user) } # won't actually be a user. just giving it a valid model here

          it "records the originator on the ledger entry" do
            expect { subject }.to change { store_credit.store_credit_ledger_entries.count }.by(2)
            expect(store_credit.store_credit_ledger_entries.last.originator).to eq originator
          end
        end
      end
    end

    describe "#void" do
      let(:auth_code)    { "1-SC-20141111111111" }
      let(:store_credit) { create(:store_credit, amount_used: 150.0) }
      let(:originator) { nil }

      subject do
        store_credit.void(auth_code, action_originator: originator)
      end

      context "no event found for auth_code" do
        it "does not add an entry to the ledger" do
          expect { subject }.to_not change { store_credit.store_credit_ledger_entries.count }
        end
      end

      context "capture event found for auth_code" do
        let(:captured_amount) { 10.0 }
        let!(:capture_event) {
          create(:store_credit_auth_event,
                                      action: Spree::StoreCredit::CAPTURE_ACTION,
                                      authorization_code: auth_code,
                                      amount: captured_amount,
                                      store_credit: store_credit)
        }

        it "does not add an entry to the ledger" do
          expect { subject }.to_not change { store_credit.store_credit_ledger_entries.count }
        end
      end

      context "auth event found for auth_code" do
        let(:auth_event) { create(:store_credit_auth_event) }

        let(:authorized_amount) { 10.0 }
        let!(:auth_event) {
          create(:store_credit_auth_event,
                                   authorization_code: auth_code,
                                   amount: authorized_amount,
                                   store_credit: store_credit)
        }

        it "will add a 'pending' entry to the ledger" do
          expect { subject }.to change { store_credit.store_credit_ledger_entries.pending.count }.by(1)
        end

        it "will set the expected balance" do
          expect { subject }.to change { store_credit.balance }.by(authorized_amount)
        end

        it "will not change the liability balance" do
          expect { subject }.to_not change{ store_credit.liability_balance }
        end

        context "originator is present" do
          let(:originator) { create(:user) } # won't actually be a user. just giving it a valid model here

          it "records the originator on the ledger entry" do
            expect { subject }.to change { store_credit.store_credit_ledger_entries.pending.count }.by(1)
            expect(store_credit.store_credit_ledger_entries.pending.last.originator).to eq originator
          end
        end
      end
    end

    describe "#credit" do
      let(:event_auth_code) { "1-SC-20141111111111" }
      let(:amount_used)     { 10.0 }
      let(:store_credit)    { create(:store_credit, amount_used: amount_used) }
      let!(:capture_event)  {
        create(:store_credit_auth_event,
                                     action: Spree::StoreCredit::CAPTURE_ACTION,
                                     authorization_code: event_auth_code,
                                     amount: captured_amount,
                                     store_credit: store_credit)
      }
      let(:originator) { nil }

      subject { store_credit.credit(credit_amount, auth_code, currency, action_originator: originator) }

      context "currency does not match" do
        let(:currency)        { "AUD" }
        let(:credit_amount)   { 5.0 }
        let(:captured_amount) { 100.0 }
        let(:auth_code)       { event_auth_code }

        it "does not add an entry to the ledger" do
          expect { subject }.to_not change { store_credit.store_credit_ledger_entries.count }
        end
      end

      context "unable to find capture event" do
        let(:currency)        { "USD" }
        let(:credit_amount)   { 5.0 }
        let(:captured_amount) { 100.0 }
        let(:auth_code)       { "UNKNOWN_CODE" }

        it "does not add an entry to the ledger" do
          expect { subject }.to_not change { store_credit.store_credit_ledger_entries.count }
        end
      end

      context "amount is more than what is captured" do
        let(:currency)        { "USD" }
        let(:credit_amount)   { 100.0 }
        let(:captured_amount) { 5.0 }
        let(:auth_code)       { event_auth_code }

        it "does not add an entry to the ledger" do
          expect { subject }.to_not change { store_credit.store_credit_ledger_entries.count }
        end
      end

      context "amount is successfully credited" do
        let(:currency)        { "USD" }
        let(:credit_amount)   { 5.0 }
        let(:captured_amount) { 100.0 }
        let(:auth_code)       { event_auth_code }

        context "credit_to_new_allocation is set" do
          before { Spree::Config[:credit_to_new_allocation] = true }

          it "does not create a new store credit ledger entry on the parent store credit" do
            expect { subject }.to_not change { store_credit.store_credit_ledger_entries.count }
          end
        end

        context "credit_to_new_allocation is not set" do

          it "adds an entry to the ledger" do
            expect { subject }.to change { store_credit.store_credit_ledger_entries.count }.by(1)
          end

          it "will up the balance with the amount credited" do
            expect { subject }.to change { store_credit.liability_balance }.by(credit_amount)
          end
        end
      end
    end

    describe "#update_amount" do
      let(:updating_user) { create(:user) }
      let(:update_reason) { create(:store_credit_update_reason) }

      subject { store_credit.update_amount(amount, update_reason, updating_user) }

      context "amount is valid" do
        let(:amount) { 10.0 }

        before { store_credit.update_attributes!(amount: 30.0) }

        it "adds an entry to the ledger" do
          expect { subject }.to change { store_credit.store_credit_ledger_entries.count }.by(1)
        end

        it "records the originator on the ledger entry" do
          subject
          expect(Spree::StoreCreditLedgerEntry.last.originator).to eq updating_user
        end

        it "will update the balance to match the updated amount" do
          # amount is 30
          # adjusted amount is 10
          # expecting the balance to change by -20
          expect { subject }.to change { store_credit.liability_balance }.by(-20)
        end

        it "will return the correct ledger balance" do
          # amount is 30
          # adjusted amount is 10
          # expecting the balance to return the adjusted amount
          subject
          expect(store_credit.liability_balance).to eql amount
        end

        context "and larger then the current store credit amount" do
          let(:amount) { 50.0 }

          it "will update the balance to match the updated amount" do
            # amount is 30
            # adjusted amount is 50
            # expecting the balance to change by 20
            expect { subject }.to change { store_credit.liability_balance }.by(20)
          end

          it "will return the correct ledger balance" do
            # amount is 30
            # adjusted amount is 50
            # expecting the balance to return the adjusted amount
            subject
            expect(store_credit.liability_balance).to eql amount
          end
        end
      end

      context "amount is invalid" do
        let(:amount) { -10.0 }

        it "doesn't create a store credit ledger entry" do
          expect { subject }.to_not change { store_credit.store_credit_ledger_entries.count }
        end
      end
    end

    describe "#invalidate" do
      let(:invalidation_user) { create(:user) }
      let(:invalidation_reason) { create(:store_credit_update_reason) }

      before do
        store_credit.save!
      end

      subject { store_credit.invalidate(invalidation_reason, invalidation_user) }

      context "there is a captured authorization" do
        before do
          auth_code = store_credit.authorize(5.0, "USD")
          store_credit.capture(5.0, auth_code, "USD")
        end

        it "adds an entry to the ledger" do
          expect { subject }.to change { store_credit.store_credit_ledger_entries.count }.by(1)
        end

        it "will lower the ledger balance with the last remaining balance" do
          remaining_balance = store_credit.liability_balance
          expect { subject }.to change { store_credit.liability_balance }.by(-1 * remaining_balance)
        end

        it "will made the ledger balance be 0.0" do
          subject
          expect(store_credit.liability_balance).to eql 0.0
        end

        it "records the originator on the ledger entry" do
          subject
          expect(store_credit.store_credit_ledger_entries.last.originator).to eq invalidation_user
        end
      end
    end
  end
end
