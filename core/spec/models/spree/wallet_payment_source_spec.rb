require 'spec_helper'

describe Spree::WalletPaymentSource, type: :model do
  subject { Spree::WalletPaymentSource }

  describe "validation" do
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
