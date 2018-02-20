# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::WalletPaymentSource, type: :model do
  subject { Spree::WalletPaymentSource }

  describe "validation" do
    context 'with a non-PaymentSource model' do
      with_model 'NonPaymentSource', scope: :all do
        model do
          # We have to set this up or else `inverse_of` prevents us from testing our code
          has_many :wallet_payment_sources, class_name: 'Spree::WalletPaymentSource', as: :payment_source, inverse_of: :payment_source
        end
      end

      let(:payment_source) { NonPaymentSource.create! }

      it "errors when `payment_source` is not a `Spree::PaymentSource`" do
        wallet_payment_source = Spree::WalletPaymentSource.new(
          payment_source: payment_source,
          user: create(:user)
        )

        expect(wallet_payment_source).not_to be_valid
        expect(wallet_payment_source.errors.messages).to eq(
          { payment_source: ["has to be a Spree::PaymentSource"] }
        )
      end
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
