# frozen_string_literal: true

RSpec.shared_examples "a payment source" do
  subject(:payment_source) { described_class.new }

  describe "attributes" do
    it { is_expected.to respond_to(:imported) }
    it { is_expected.to respond_to(:name) }
  end

  describe "#associations" do
    it { is_expected.to respond_to(:payments) }
    it { is_expected.to respond_to(:user) }
  end

  describe "#wallet_payment_sources" do
    let(:user) { create(:user) }

    let!(:wallet_payment_source) do
      # There are nasty validations that do not matter for this test
      payment_source.save(validate: false)
      Spree::WalletPaymentSource.new(user:, payment_source:).tap do |wps|
        wps.save(validate: false)
      end
    end

    context "when the payment source gets destroyed" do
      it "destroys the wallet payment source" do
        expect { payment_source.destroy }.to change { Spree::WalletPaymentSource.count }.by(-1)
      end
    end
  end

  describe "#can_capture?" do
    it "should be true if payment is pending" do
      payment = mock_model(Spree::Payment, pending?: true, created_at: Time.current)
      expect(payment_source.can_capture?(payment)).to be true
    end

    it "should be true if payment is checkout" do
      payment = mock_model(Spree::Payment, pending?: false, checkout?: true, created_at: Time.current)
      expect(payment_source.can_capture?(payment)).to be true
    end
  end

  describe "#can_void?" do
    it "should call payment#can_void?" do
      payment = mock_model(Spree::Payment, can_void?: true)
      expect(payment).to receive(:can_void?)
      payment_source.can_void?(payment)
    end
  end

  describe "#can_credit?" do
    it "should be false if payment is not completed" do
      payment = mock_model(Spree::Payment, completed?: false)
      expect(payment_source.can_credit?(payment)).to be false
    end

    it "should be false when credit_allowed is zero" do
      payment = mock_model(Spree::Payment, completed?: true, credit_allowed: 0, order: mock_model(Spree::Order, payment_state: "credit_owed"))
      expect(payment_source.can_credit?(payment)).to be false
    end
  end

  describe "#first_name" do
    before do
      payment_source.name = "Ludwig van Beethoven"
    end

    it "extracts the first name" do
      expect(payment_source.first_name).to eq "Ludwig"
    end
  end

  describe "#last_name" do
    before do
      payment_source.name = "Ludwig van Beethoven"
    end

    it "extracts the last name" do
      expect(payment_source.last_name).to eq "van Beethoven"
    end
  end
end
