# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Wallet::AddPaymentSourcesToWallet, type: :model do
  let(:order) { create(:order_ready_to_complete) }
  let(:user) { order.user }

  describe "#add_to_wallet" do
    subject { described_class.new(order) }

    before do
      # Ensure the payment is reusable, otherwise false positives occur
      allow_any_instance_of(Spree::CreditCard).to receive(:reusable?).and_return(true)
    end

    it "saves the payment source" do
      expect { subject.add_to_wallet }.to change {
        order.user.wallet.wallet_payment_sources.count
      }.by(1)
    end

    context "when the default wallet payment source is used and a more recent wallet payment exists" do
      before do
        credit_card_one = user.wallet.add(create(:credit_card, user:))
        user.wallet.add(create(:credit_card, user:))
        user.wallet.default_wallet_payment_source = credit_card_one # must be the first created card
        order.payments.first.update!(source: credit_card_one.payment_source)
      end

      it "does not make a new wallet payment source" do
        expect { subject.add_to_wallet }.to_not change {
          order.user.wallet.wallet_payment_sources.count
        }
      end

      it "does not change the default wallet payment source" do
        expect { subject.add_to_wallet }.to_not change {
          user.wallet.default_wallet_payment_source
        }
      end
    end
  end
end
