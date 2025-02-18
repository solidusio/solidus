# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::WalletPaymentSource, type: :model do
  subject { Spree::WalletPaymentSource }

  describe "validation" do
    let(:user) { create(:user) }

    context "with a non-PaymentSource model" do
      # RESOURCE FIXTURE
      before(:all) do
        # Database
        class CreateNonPaymentSources < ActiveRecord::Migration[5.1]
          def change
            create_table(:non_payment_sources)
          end
        end
        CreateNonPaymentSources.migrate(:up)

        # Model
        class NonPaymentSource < ActiveRecord::Base
          # We have to set this up or else `inverse_of` prevents us from testing our code
          has_many :wallet_payment_sources, class_name: "Spree::WalletPaymentSource", as: :payment_source, inverse_of: :payment_source
        end
      end

      # TEAR DOWN RESOURCE FIXTURE
      after(:all) do
        # Database
        CreateNonPaymentSources.migrate(:down)
        Object.send(:remove_const, :CreateNonPaymentSources)

        # Model
        Object.send(:remove_const, :NonPaymentSource)
      end

      let(:payment_source) { NonPaymentSource.create! }

      it "errors when `payment_source` is not a `Spree::PaymentSource`" do
        wallet_payment_source = Spree::WalletPaymentSource.new(
          payment_source:,
          user:
        )

        expect(wallet_payment_source).not_to be_valid
        expect(wallet_payment_source.errors.messages).to eq(
          {payment_source: ["is not a valid payment source"]}
        )
      end
    end

    it "is invalid if `payment_source` is already in the user's wallet" do
      credit_card = create(:credit_card, user:)
      Spree::WalletPaymentSource.create(
        payment_source: credit_card,
        user:
      )
      wallet_payment_source = subject.new(
        payment_source: credit_card,
        user:
      )
      expect(wallet_payment_source).not_to be_valid
      expect(wallet_payment_source.errors.messages).to eq(
        {user_id: ["already has this payment source in their wallet"]}
      )
    end

    it "is invalid when `payment_source` is not owned by the user" do
      wallet_payment_source = subject.new(
        payment_source: create(:credit_card),
        user:
      )
      expect(wallet_payment_source).not_to be_valid
      expect(wallet_payment_source.errors.messages).to eq(
        {payment_source: ["does not belong to the user associated with the order"]}
      )
    end

    it "is valid with a `credit_card` as `payment_source`" do
      valid_attrs = {
        payment_source: create(:credit_card, user:),
        user:
      }
      expect(subject.new(valid_attrs)).to be_valid
    end

    it "is valid with `store_credit` as `payment_source`" do
      valid_attrs = {
        payment_source: create(:store_credit, user:),
        user:
      }
      expect(subject.new(valid_attrs)).to be_valid
    end
  end
end
