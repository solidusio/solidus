# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Wallet::AddPaymentSourcesToWallet, type: :model do
  let(:order) { create(:order_ready_to_complete) }

  describe '#add_to_wallet' do
    subject { described_class.new(order) }

    it 'saves the payment source' do
      expect { subject.add_to_wallet }.to change {
        order.user.wallet.wallet_payment_sources.count
      }.by(1)
    end
  end
end
