require 'spec_helper'

describe Spree::WalletPaymentSource, type: :model do
  subject { Spree::WalletPaymentSource }

  context "validation" do
    it "errors when `payment_source` is not a `Spree::PaymentSource`" do
      invalid_payment_source_attrs = {
        payment_source: create(:address),
        user: create(:user)
      }

      error_message = { payment_source: ["has to be a Spree::PaymentSource"] }
      wallet_payment_source = subject.new(invalid_payment_source_attrs)

      expect(wallet_payment_source).not_to be_valid
      expect(wallet_payment_source.errors.messages).to eql error_message
    end

    it "is valid with a `credit_card` as `payment_source`" do
      valid_attrs = {
        payment_source: create(:credit_card),
        user: create(:user)
      }
      expect(subject.new(valid_attrs)).to be_valid
    end

    it "is valid with `store_credit` as `payment_source`" do
      valid_attrs = {
        payment_source: create(:store_credit),
        user: create(:user)
      }
      expect(subject.new(valid_attrs)).to be_valid
    end
  end
end
