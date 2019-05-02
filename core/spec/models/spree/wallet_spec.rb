# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Wallet, type: :model do
  let(:user) { create(:user) }
  let(:credit_card) { create(:credit_card, user_id: user.id) }
  let(:store_credit) { create(:store_credit, user_id: user.id) }
  subject(:wallet) { Spree::Wallet.new(user) }

  describe "#add" do
    context "with valid payment source" do
      it "creates a wallet_payment_source for this user's wallet" do
        expect { subject.add(credit_card) }.to change(Spree::WalletPaymentSource, :count).by(1)
      end

      it "only creates the payment source once" do
        subject.add(credit_card)
        expect { subject.add(credit_card) }.to_not change(Spree::WalletPaymentSource, :count)
      end
    end
  end

  describe "#remove" do
    context "with payment_source not in the wallet" do
      it "will raise a RecordNotFound exception" do
        expect { subject.remove(credit_card) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "with the payment_source in the wallet" do
      before { subject.add(credit_card) }
      it "will remove the payment source from the wallet" do
        expect { subject.remove(credit_card) }.to change(Spree::WalletPaymentSource, :count).by(-1)
      end
    end
  end

  describe "#wallet_payment_sources" do
    context "with no payment sources" do
      it "returns an empty Array" do
        expect(subject.wallet_payment_sources).to eql []
      end
    end

    context "with payment sources" do
      let!(:wallet_credit_card) { subject.add(credit_card) }
      let!(:wallet_store_credit) { subject.add(store_credit) }

      it "returns all the payment sources" do
        expect(subject.wallet_payment_sources).to include(wallet_credit_card, wallet_store_credit)
      end
    end
  end

  describe "#find" do
    context "with no payment sources in the wallet" do
      it "returns nil" do
        expect(subject.find(1)).to be_nil
      end
    end

    context "with payment sources in the wallet" do
      let(:wallet_credit_card) { subject.add(credit_card) }

      it "finds the wallet payment source by id" do
        expect(subject.find(wallet_credit_card.id)).to eql wallet_credit_card
      end
    end
  end

  describe "#default_wallet_payment_source=" do
    context "with no current default" do
      let!(:wallet_credit_card) { subject.add(credit_card) }

      it "marks the passed in payment source as default" do
        expect { subject.default_wallet_payment_source = wallet_credit_card }.to(
          change(subject, :default_wallet_payment_source).
            from(nil).
            to(wallet_credit_card)
        )
      end

      context "assigning nil" do
        it "remains unset" do
          expect(subject.default_wallet_payment_source).to be_nil
          subject.default_wallet_payment_source = nil
          expect(subject.default_wallet_payment_source).to be_nil
        end
      end
    end

    context "with a default" do
      let!(:wallet_credit_card) { subject.add(credit_card) }

      before { subject.default_wallet_payment_source = wallet_credit_card }

      context "assigning a new default" do
        let!(:wallet_store_credit) { subject.add(store_credit) }

        it "sets the new payment source as the default" do
          expect {
            subject.default_wallet_payment_source = wallet_store_credit
          }.to change{ subject.default_wallet_payment_source }.from(wallet_credit_card).to(wallet_store_credit)
        end
      end

      context "assigning same default" do
        it "does not change the default payment source" do
          expect {
            subject.default_wallet_payment_source = wallet_credit_card
          }.not_to change{ subject.default_wallet_payment_source }
        end
      end

      context "assigning nil" do
        it "clears the default payment source" do
          expect {
            subject.default_wallet_payment_source = nil
          }.to change{ subject.default_wallet_payment_source }.to nil
        end
      end
    end

    context 'with a wallet payment source that does not belong to the wallet' do
      let(:other_wallet_credit_card) { other_wallet.add(other_credit_card) }
      let(:other_wallet) { Spree::Wallet.new(other_user) }
      let(:other_credit_card) { create(:credit_card, user_id: other_user.id) }
      let(:other_user) { create(:user) }

      it 'raises an error' do
        expect {
          wallet.default_wallet_payment_source = other_wallet_credit_card
        }.to raise_error(Spree::Wallet::Unauthorized)
      end
    end
  end

  describe "#default_wallet_payment_source" do
    context "with no default payment source present" do
      it "will return nil" do
        expect(subject.default_wallet_payment_source).to be_nil
      end
    end

    context "with a default payment source" do
      let!(:wallet_credit_card) { subject.add(credit_card) }
      before { subject.default_wallet_payment_source = wallet_credit_card }

      it "will return the wallet payment source" do
        expect(subject.default_wallet_payment_source).to eql wallet_credit_card
      end
    end
  end
end
