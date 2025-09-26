# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::StoreCredit do
  include ActiveSupport::Testing::TimeHelpers

  let(:currency) { "TEST" }
  let(:store_credit) { build(:store_credit, store_credit_attrs) }
  let(:store_credit_attrs) { {} }

  describe "callbacks" do
    subject { store_credit.save }

    context "amount used is greater than zero" do
      let(:store_credit) { create(:store_credit, amount: 100, amount_used: 1) }

      describe "#discard" do
        subject { store_credit.discard }

        it "can not delete the store credit" do
          subject
          expect(store_credit.reload).to eq store_credit
          expect(store_credit.errors[:amount_used]).to include("is greater than zero. Can not delete store credit")
          expect(store_credit).not_to be_discarded
        end
      end
    end

    context "category is a non-expiring type" do
      let!(:secondary_credit_type) { create(:secondary_credit_type) }
      let(:store_credit) { build(:store_credit, credit_type: nil) }

      before do
        allow(store_credit.category).to receive(:non_expiring?).and_return(true)
      end

      it "sets the credit type to non-expiring" do
        subject
        expect(store_credit.credit_type.name).to eq secondary_credit_type.name
      end
    end

    context "category is an expiring type" do
      before do
        allow(store_credit.category).to receive(:non_expiring?).and_return(false)
      end

      it "sets the credit type to expiring" do
        subject
        expect(store_credit.credit_type.name).to eq "Expiring"
      end
    end

    context "the type is set" do
      let!(:secondary_credit_type) { create(:secondary_credit_type) }
      let(:store_credit) { build(:store_credit, credit_type: secondary_credit_type) }

      before do
        allow(store_credit.category).to receive(:non_expiring?).and_return(false)
      end

      it "doesn't overwrite the type" do
        expect { subject }.to_not change { store_credit.credit_type }
      end
    end
  end

  describe "validations" do
    describe "used amount should not be greater than the credited amount" do
      context "the used amount is defined" do
        let(:invalid_store_credit) { build(:store_credit, amount: 100, amount_used: 150) }

        it "should not be valid" do
          expect(invalid_store_credit).not_to be_valid
        end

        it "should set the correct error message" do
          invalid_store_credit.valid?
          expect(invalid_store_credit.errors.full_messages).to include("Amount Used cannot be greater than the credited amount")
        end
      end

      context "the used amount is not defined yet" do
        let(:store_credit) { build(:store_credit, amount: 100) }

        it "should be valid" do
          expect(store_credit).to be_valid
        end
      end
    end

    describe "amount used less than or equal to amount" do
      subject { build(:store_credit, amount_used: 101.0, amount: 100.0) }

      it "is not valid" do
        expect(subject).not_to be_valid
      end

      it "adds an error message about the invalid amount used" do
        subject.valid?
        expect(subject.errors[:amount_used]).to include("cannot be greater than the credited amount")
      end
    end

    describe "amount authorized less than or equal to amount" do
      subject { build(:store_credit, amount_authorized: 101.0, amount: 100.0) }

      it "is not valid" do
        expect(subject).not_to be_valid
      end

      it "adds an error message about the invalid authorized amount" do
        subject.valid?
        expect(subject.errors[:amount_authorized]).to include(" exceeds the available credit")
      end
    end

    describe "editing category" do
      let!(:store_credit) { create(:store_credit) }
      let!(:test_category) { create(:store_credit_category, name: "Testing") }

      subject { store_credit.update(category: test_category) }

      it "returns false" do
        expect(subject).to eq false
      end

      it "category doesn't change" do
        expect { subject }.not_to change { store_credit.reload.category }
      end

      it "adds an error message about not being able to edit the category" do
        subject
        expect(store_credit.errors[:category]).to include("cannot be modified")
      end
    end
  end

  describe "#display_number" do
    it "returns the category name" do
      expect(store_credit.display_number).to eq("Exchange")
    end
  end

  describe "#display_amount" do
    it "returns a Spree::Money instance" do
      expect(store_credit.display_amount).to be_instance_of(Spree::Money)
    end
  end

  describe "#display_amount_used" do
    it "returns a Spree::Money instance" do
      expect(store_credit.display_amount_used).to be_instance_of(Spree::Money)
    end
  end

  describe "#display_amount_authorized" do
    it "returns a Spree::Money instance" do
      expect(store_credit.display_amount_authorized).to be_instance_of(Spree::Money)
    end
  end

  describe "#amount=" do
    let(:store_credit) { described_class.new(amount:) }

    context "with an imperial price format" do
      let(:amount) { "1,000.50" }

      before do
        expect(I18n).to receive(:t).with(:"number.currency.format.separator") do
          "."
        end
      end

      it "sets the correct amount" do
        expect(store_credit.amount).to eq(1000.5)
      end
    end

    context "with an european price format" do
      let(:amount) { "1.000,50" }

      before do
        expect(I18n).to receive(:t).with(:"number.currency.format.separator") do
          ","
        end
      end

      it "sets the correct amount" do
        expect(store_credit.amount).to eq(1000.5)
      end
    end
  end

  describe "#amount_remaining" do
    context "invalidated" do
      before { allow(store_credit).to receive(:invalidated?) { true } }
      it { expect(store_credit.amount_remaining).to eq 0.0 }
    end

    context "the amount_used is not defined" do
      context "the authorized amount is not defined" do
        it "returns the credited amount" do
          expect(store_credit.amount_remaining).to eq store_credit.amount
        end
      end
      context "the authorized amount is defined" do
        let(:authorized_amount) { 15.00 }

        before { store_credit.update(amount_authorized: authorized_amount) }

        it "subtracts the authorized amount from the credited amount" do
          expect(store_credit.amount_remaining).to eq(store_credit.amount - authorized_amount)
        end
      end
    end

    context "the amount_used is defined" do
      let(:amount_used) { 10.0 }

      before { store_credit.update(amount_used:) }

      context "the authorized amount is not defined" do
        it "subtracts the amount used from the credited amount" do
          expect(store_credit.amount_remaining).to eq(store_credit.amount - amount_used)
        end
      end

      context "the authorized amount is defined" do
        let(:authorized_amount) { 15.00 }

        before { store_credit.update(amount_authorized: authorized_amount) }

        it "subtracts the amount used and the authorized amount from the credited amount" do
          expect(store_credit.amount_remaining).to eq(store_credit.amount - amount_used - authorized_amount)
        end
      end
    end
  end

  describe "#authorize" do
    context "amount is valid" do
      let(:authorization_amount) { 1.0 }
      let(:added_authorization_amount) { 3.0 }
      let(:originator) { nil }

      context "amount has not been authorized yet" do
        before { store_credit.update(amount_authorized: authorization_amount) }

        it "returns true" do
          expect(store_credit.authorize(store_credit.amount - authorization_amount, store_credit.currency)).to be_truthy
        end

        it "adds the new amount to authorized amount" do
          store_credit.authorize(added_authorization_amount, store_credit.currency)
          expect(store_credit.reload.amount_authorized).to eq(authorization_amount + added_authorization_amount)
        end

        context "originator is present" do
          let(:originator) { create(:user) } # won't actually be a user. just giving it a valid model here

          subject { store_credit.authorize(added_authorization_amount, store_credit.currency, action_originator: originator) }

          it "records the originator" do
            expect { subject }.to change { Spree::StoreCreditEvent.count }.by(1)
            expect(Spree::StoreCreditEvent.last.originator).to eq originator
          end
        end
      end

      context "authorization has already happened" do
        let!(:auth_event) { create(:store_credit_auth_event, store_credit:) }

        before { store_credit.update(amount_authorized: store_credit.amount) }

        it "returns true" do
          expect(store_credit.authorize(store_credit.amount, store_credit.currency, action_authorization_code: auth_event.authorization_code)).to be true
        end
      end
    end

    context "amount is invalid" do
      it "returns false" do
        expect(store_credit.authorize(store_credit.amount * 2, store_credit.currency)).to be false
      end
    end
  end

  describe "#validate_authorization" do
    context "insufficient funds" do
      subject { store_credit.validate_authorization(store_credit.amount * 2, store_credit.currency) }

      it "returns false" do
        expect(subject).to be false
      end

      it "adds an error to the model" do
        subject
        expect(store_credit.errors.full_messages).to include("Store credit amount remaining is not sufficient")
      end
    end

    context "currency mismatch" do
      subject { store_credit.validate_authorization(store_credit.amount, "EUR") }

      it "returns false" do
        expect(subject).to be false
      end

      it "adds an error to the model" do
        subject
        expect(store_credit.errors.full_messages).to include("Store credit currency does not match order currency")
      end
    end

    context "valid authorization" do
      subject { store_credit.validate_authorization(store_credit.amount, store_credit.currency) }

      it "returns true" do
        expect(subject).to be true
      end
    end

    context "troublesome floats" do
      if Gem::Requirement.new("~> 3.0.0") === Gem::Version.new(BigDecimal::VERSION)
        # BigDecimal 2.0.0> 8.21.to_d # => 0.821e1 (all good!)
        # BigDecimal 3.0.0> 8.21.to_d # => 0.8210000000000001e1 (`8.21.to_d < 8.21` is `true`!!!)
        # BigDecimal 3.1.4> 8.21.to_d # => 0.821e1 (all good!)
        before { pending "https://github.com/rails/rails/issues/42098; https://github.com/ruby/bigdecimal/issues/192" }
      end

      let(:store_credit_attrs) { {amount: 8.21} }

      subject { store_credit.validate_authorization(store_credit_attrs[:amount], store_credit.currency) }

      it { is_expected.to be_truthy }
    end
  end

  describe "#capture" do
    let(:authorized_amount) { 10.00 }
    let(:auth_code) { "23-SC-20140602164814476128" }

    before do
      @original_authed_amount = store_credit.amount_authorized
      @auth_code = store_credit.authorize(authorized_amount, store_credit.currency)
    end

    context "insufficient funds" do
      subject { store_credit.capture(authorized_amount * 2, @auth_code, store_credit.currency) }

      it "returns false" do
        expect(subject).to be false
      end

      it "adds an error to the model" do
        subject
        expect(store_credit.errors.full_messages).to include("Unable to capture more than authorized amount")
      end

      it "does not update the store credit model" do
        expect { subject }.to_not change { store_credit }
      end
    end

    context "currency mismatch" do
      subject { store_credit.capture(authorized_amount, @auth_code, "EUR") }

      it "returns false" do
        expect(subject).to be false
      end

      it "adds an error to the model" do
        subject
        expect(store_credit.errors.full_messages).to include("Store credit currency does not match order currency")
      end

      it "does not update the store credit model" do
        expect { subject }.to_not change { store_credit }
      end
    end

    context "valid capture" do
      let(:remaining_authorized_amount) { 1 }
      let(:originator) { nil }

      subject { store_credit.capture(authorized_amount - remaining_authorized_amount, @auth_code, store_credit.currency, action_originator: originator) }

      it "returns true" do
        expect(subject).to be_truthy
      end

      it "updates the authorized amount to the difference between the store credits total authed amount and the authorized amount for this event" do
        subject
        expect(store_credit.reload.amount_authorized).to eq(@original_authed_amount)
      end

      it "updates the used amount to the current used amount plus the captured amount" do
        subject
        expect(store_credit.reload.amount_used).to eq authorized_amount - remaining_authorized_amount
      end

      context "originator is present" do
        let(:originator) { create(:user) } # won't actually be a user. just giving it a valid model here

        it "records the originator" do
          expect { subject }.to change { Spree::StoreCreditEvent.count }.by(1)
          expect(Spree::StoreCreditEvent.last.originator).to eq originator
        end
      end
    end
  end

  describe "#void" do
    let(:auth_code) { "1-SC-20141111111111" }
    let(:store_credit) { create(:store_credit, amount_used: 150.0) }
    let(:originator) { nil }

    subject do
      store_credit.void(auth_code, action_originator: originator)
    end

    context "no event found for auth_code" do
      it "returns false" do
        expect(subject).to be false
      end

      it "adds an error to the model" do
        subject
        expect(store_credit.errors.full_messages).to include("Unable to void code: #{auth_code}")
      end
    end

    context "capture event found for auth_code" do
      let(:captured_amount) { 10.0 }
      let!(:capture_event) {
        create(:store_credit_auth_event,
          action: Spree::StoreCredit::CAPTURE_ACTION,
          authorization_code: auth_code,
          amount: captured_amount,
          store_credit:)
      }

      it "returns false" do
        expect(subject).to be false
      end

      it "does not change the amount used on the store credit" do
        expect { subject }.to_not change { store_credit.amount_used.to_f }
      end
    end

    context "auth event found for auth_code" do
      let(:auth_event) { create(:store_credit_auth_event) }

      let(:authorized_amount) { 10.0 }
      let!(:auth_event) {
        create(:store_credit_auth_event,
          authorization_code: auth_code,
          amount: authorized_amount,
          store_credit:)
      }

      it "returns true" do
        expect(subject).to be true
      end

      it "returns the authorized amount to the store credit" do
        expect { subject }.to change { store_credit.amount_authorized.to_f }.by(-authorized_amount)
      end

      context "originator is present" do
        let(:originator) { create(:user) } # won't actually be a user. just giving it a valid model here

        it "records the originator" do
          expect { subject }.to change { Spree::StoreCreditEvent.count }.by(1)
          expect(Spree::StoreCreditEvent.last.originator).to eq originator
        end
      end
    end
  end

  describe "#credit" do
    let(:event_auth_code) { "1-SC-20141111111111" }
    let(:amount_used) { 10.0 }
    let(:store_credit) { create(:store_credit, amount_used:) }
    let!(:capture_event) {
      create(:store_credit_auth_event,
        action: Spree::StoreCredit::CAPTURE_ACTION,
        authorization_code: event_auth_code,
        amount: captured_amount,
        store_credit:)
    }
    let(:originator) { nil }

    subject { store_credit.credit(credit_amount, auth_code, currency, action_originator: originator) }

    context "currency does not match" do
      let(:currency) { "AUD" }
      let(:credit_amount) { 5.0 }
      let(:captured_amount) { 100.0 }
      let(:auth_code) { event_auth_code }

      it "returns false" do
        expect(subject).to be false
      end

      it "adds an error message about the currency mismatch" do
        subject
        expect(store_credit.errors.full_messages).to include("Store credit currency does not match order currency")
      end
    end

    context "unable to find capture event" do
      let(:currency) { "USD" }
      let(:credit_amount) { 5.0 }
      let(:captured_amount) { 100.0 }
      let(:auth_code) { "UNKNOWN_CODE" }

      it "returns false" do
        expect(subject).to be false
      end

      it "adds an error message about the currency mismatch" do
        subject
        expect(store_credit.errors.full_messages).to include("Unable to credit code: #{auth_code}")
      end
    end

    context "amount is more than what is captured" do
      let(:currency) { "USD" }
      let(:credit_amount) { 100.0 }
      let(:captured_amount) { 5.0 }
      let(:auth_code) { event_auth_code }

      it "returns false" do
        expect(subject).to be false
      end

      it "adds an error message about the currency mismatch" do
        subject
        expect(store_credit.errors.full_messages).to include("Unable to credit code: #{auth_code}")
      end
    end

    context "amount is successfully credited" do
      let(:currency) { "USD" }
      let(:credit_amount) { 5.0 }
      let(:captured_amount) { 100.0 }
      let(:auth_code) { event_auth_code }

      context "credit_to_new_allocation is set" do
        before { stub_spree_preferences(credit_to_new_allocation: true) }

        it "returns true" do
          expect(subject).to be true
        end

        it "creates a new store credit record" do
          expect { subject }.to change { Spree::StoreCredit.count }.by(1)
        end

        it "does not create a new store credit event on the parent store credit" do
          expect { subject }.to_not change { store_credit.store_credit_events.count }
        end

        context "credits the passed amount to a new store credit record" do
          before do
            subject
            @new_store_credit = Spree::StoreCredit.last
          end

          it "does not set the amount used on the originating store credit" do
            expect(store_credit.reload.amount_used).to eq amount_used
          end

          it "sets the correct amount on the new store credit" do
            expect(@new_store_credit.amount).to eq credit_amount
          end

          [:user_id, :category_id, :created_by_id, :currency, :type_id].each do |attr|
            it "sets attribute #{attr} inherited from the originating store credit" do
              expect(@new_store_credit.send(attr)).to eq store_credit.send(attr)
            end
          end

          it "sets a memo" do
            expect(@new_store_credit.memo).to eq "This is a credit from store credit ID #{store_credit.id}"
          end
        end

        context "originator is present" do
          let(:originator) { create(:user) } # won't actually be a user. just giving it a valid model here

          it "records the originator" do
            expect { subject }.to change { Spree::StoreCreditEvent.count }.by(1)
            expect(Spree::StoreCreditEvent.last.originator).to eq originator
          end
        end
      end

      context "credit_to_new_allocation is not set" do
        it "returns true" do
          expect(subject).to be true
        end

        it "credits the passed amount to the store credit amount used" do
          subject
          expect(store_credit.reload.amount_used).to eq(amount_used - credit_amount)
        end

        it "creates a new store credit event" do
          expect { subject }.to change { store_credit.store_credit_events.count }.by(1)
        end
      end
    end
  end

  describe "#amount_used" do
    context "amount used is not defined" do
      subject { Spree::StoreCredit.new }

      it "returns zero" do
        expect(subject.amount_used).to be_zero
      end
    end

    context "amount used is defined" do
      let(:amount_used) { 100.0 }

      subject { create(:store_credit, amount_used:) }

      it "returns the attribute value" do
        expect(subject.amount_used).to eq amount_used
      end
    end
  end

  describe "#amount_authorized" do
    context "amount authorized is not defined" do
      subject { Spree::StoreCredit.new }

      it "returns zero" do
        expect(subject.amount_authorized).to be_zero
      end
    end

    context "amount authorized is defined" do
      let(:amount_authorized) { 100.0 }

      subject { create(:store_credit, amount_authorized:) }

      it "returns the attribute value" do
        expect(subject.amount_authorized).to eq amount_authorized
      end
    end
  end

  describe "#can_capture?" do
    let(:store_credit) { create(:store_credit) }
    let(:payment) { create(:payment, state: payment_state) }

    subject { store_credit.can_capture?(payment) }

    context "pending payment" do
      let(:payment_state) { "pending" }

      it "returns true" do
        expect(subject).to be true
      end
    end

    context "checkout payment" do
      let(:payment_state) { "checkout" }

      it "returns true" do
        expect(subject).to be true
      end
    end

    context "void payment" do
      let(:payment_state) { Spree::StoreCredit::VOID_ACTION }

      it "returns false" do
        expect(subject).to be false
      end
    end

    context "invalid payment" do
      let(:payment_state) { "invalid" }

      it "returns false" do
        expect(subject).to be false
      end
    end

    context "complete payment" do
      let(:payment_state) { "completed" }

      it "returns false" do
        expect(subject).to be false
      end
    end
  end

  describe "#can_void?" do
    let(:store_credit) { create(:store_credit) }
    let(:payment) { create(:payment, state: payment_state) }

    subject { store_credit.can_void?(payment) }

    context "pending payment" do
      let(:payment_state) { "pending" }

      it "returns true" do
        expect(subject).to be true
      end
    end

    context "checkout payment" do
      let(:payment_state) { "checkout" }

      it "returns false" do
        expect(subject).to be false
      end
    end

    context "void payment" do
      let(:payment_state) { Spree::StoreCredit::VOID_ACTION }

      it "returns false" do
        expect(subject).to be false
      end
    end

    context "invalid payment" do
      let(:payment_state) { "invalid" }

      it "returns false" do
        expect(subject).to be false
      end
    end

    context "complete payment" do
      let(:payment_state) { "completed" }

      it "returns false" do
        expect(subject).to be false
      end
    end
  end

  describe "#can_credit?" do
    let(:store_credit) { create(:store_credit) }
    let(:payment) { create(:payment, state: payment_state) }

    subject { store_credit.can_credit?(payment) }

    context "payment is not completed" do
      let(:payment_state) { "pending" }

      it "returns false" do
        expect(subject).to be false
      end
    end

    context "payment is completed" do
      let(:payment_state) { "completed" }

      context "credit is owed on the order" do
        before { allow(payment.order).to receive_messages(payment_state: "credit_owed") }

        context "payment doesn't have allowed credit" do
          before { allow(payment).to receive_messages(credit_allowed: 0.0) }

          it "returns false" do
            expect(subject).to be false
          end
        end

        context "payment has allowed credit" do
          before { allow(payment).to receive_messages(credit_allowed: 5.0) }

          it "returns true" do
            expect(subject).to be true
          end
        end
      end
    end

    describe "#store_event" do
      context "create" do
        context "user has one store credit" do
          let(:store_credit_amount) { 100.0 }

          subject { create(:store_credit, amount: store_credit_amount) }

          it "creates a store credit event" do
            expect { subject }.to change { Spree::StoreCreditEvent.count }.by(1)
          end

          it "makes the store credit event an allocation event" do
            expect(subject.store_credit_events.first.action).to eq Spree::StoreCredit::ALLOCATION_ACTION
          end

          it "saves the user's total store credit in the event" do
            expect(subject.store_credit_events.first.user_total_amount).to eq store_credit_amount
          end

          it "saves the user's unused store credit in the event" do
            expect(subject.store_credit_events.first.amount_remaining).to eq store_credit_amount
          end
        end

        context "user has multiple store credits" do
          let(:store_credit_amount) { 100.0 }
          let(:additional_store_credit_amount) { 200.0 }
          let(:user) { create(:user) }

          let!(:store_credits) do
            [
              create(:store_credit, user:, amount: store_credit_amount),
              create(:store_credit, user: user.reload, amount: additional_store_credit_amount)
            ]
          end

          subject { store_credits.flat_map(&:store_credit_events) }

          it "saves the user's total store credit in the event" do
            expect(subject.first.user_total_amount).to eq store_credit_amount
            expect(subject.last.user_total_amount).to eq(store_credit_amount + additional_store_credit_amount)
          end

          it "saves the user's unused store credit in the event" do
            expect(subject.first.amount_remaining).to eq store_credit_amount
            expect(subject.last.amount_remaining).to eq additional_store_credit_amount
          end
        end

        context "an action is specified" do
          it "creates an event with the set action" do
            store_credit = build(:store_credit)
            store_credit.action = Spree::StoreCredit::VOID_ACTION
            store_credit.action_authorization_code = "1-SC-TEST"

            expect { store_credit.save! }.to change { Spree::StoreCreditEvent.where(action: Spree::StoreCredit::VOID_ACTION).count }.by(1)
          end
        end
      end
    end
  end

  describe "#update_amount" do
    let(:invalidation_user) { create(:user) }
    let(:invalidation_reason) { create(:store_credit_reason) }

    subject { store_credit.update_amount(amount, invalidation_reason, invalidation_user) }

    context "amount is valid" do
      let(:amount) { 10.0 }

      before { store_credit.update!(amount: 30.0) }

      it "returns true" do
        expect(subject).to eq true
      end

      it "creates an adjustment store credit event" do
        expect { subject }.to change { store_credit.store_credit_events.where(action: Spree::StoreCredit::ADJUSTMENT_ACTION).count }.from(0).to(1)
      end

      it "sets the adjustment amount on the store credit event correctly" do
        subject
        expect(store_credit.store_credit_events.find_by(action: Spree::StoreCredit::ADJUSTMENT_ACTION).amount).to eq(-20)
      end

      it "sets the originator on the store credit event correctly" do
        subject
        expect(store_credit.store_credit_events.find_by(action: Spree::StoreCredit::ADJUSTMENT_ACTION).originator).to eq invalidation_user
      end
    end

    context "amount is invalid" do
      let(:amount) { -10.0 }

      it "returns false" do
        expect(subject).to eq false
      end

      it "doesn't create an adjustment store credit event" do
        expect { subject }.to_not change { store_credit.store_credit_events.where(action: Spree::StoreCredit::ADJUSTMENT_ACTION).count }
      end
    end
  end

  describe "#invalidate" do
    let(:invalidation_user) { create(:user) }
    let(:invalidation_reason) { create(:store_credit_reason) }

    before do
      store_credit.save!
    end

    subject { store_credit.invalidate(invalidation_reason, invalidation_user) }

    it "sets the invalidated_at field to the current time" do
      invalidated_at = 2.minutes.from_now
      travel_to(invalidated_at) do
        subject
        expect(store_credit.invalidated_at).to be_within(1.second).of invalidated_at
      end
    end

    context "there is an uncaptured authorization" do
      before { store_credit.authorize(5.0, "USD") }
      it "prevents invalidation" do
        expect { subject }.to_not change { store_credit.reload.invalidated_at }
        expect(store_credit.errors[:invalidated_at].join).to match(/uncaptured authorization/)
      end
    end

    context "there is a captured authorization" do
      before do
        auth_code = store_credit.authorize(5.0, "USD")
        store_credit.capture(5.0, auth_code, "USD")
      end

      it "can invalidate the rest of the store credit" do
        expect { subject }.to change { store_credit.reload.invalidated_at }
        expect(store_credit.errors).to be_blank
      end

      it "creates a store credit event for the invalidation" do
        expect { subject }.to change { store_credit.store_credit_events.where(action: Spree::StoreCredit::INVALIDATE_ACTION).count }.from(0).to(1)
      end

      it "assigns the originator as the user that is performing the invalidation" do
        subject
        expect(store_credit.store_credit_events.find_by(action: Spree::StoreCredit::INVALIDATE_ACTION).originator).to eq invalidation_user
      end
    end
  end

  describe "#generate_authorization_code" do
    it "doesn't rely on time for uniqueness" do
      freeze_time do
        expect(subject.generate_authorization_code).not_to eq(subject.generate_authorization_code)
      end
    end
  end
end
