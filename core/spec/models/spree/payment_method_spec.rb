# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::PaymentMethod, type: :model do
  let!(:payment_method_nil_display) do
    create(:payment_method, {
      active: true,
      available_to_users: true,
      available_to_admin: true
    })
  end
  let!(:payment_method_both_display) do
    create(:payment_method, {
      active: true,
      available_to_users: true,
      available_to_admin: true
    })
  end
  let!(:payment_method_front_display) do
    create(:payment_method, {
      active: true,
      available_to_users: true,
      available_to_admin: false
    })
  end
  let!(:payment_method_back_display) do
    create(:payment_method, {
      active: true,
      available_to_users: false,
      available_to_admin: true
    })
  end

  describe "available_to_[<users>, <admin>, <store>]" do
    context "when searching for payment methods available to users and admins" do
      subject { Spree::PaymentMethod.available_to_users.available_to_admin }

      it { is_expected.to contain_exactly(payment_method_both_display, payment_method_nil_display) }

      context "with a store" do
        let!(:extra_payment_method_both_display) do
          create(:payment_method, {
            active: true,
            available_to_users: true,
            available_to_admin: true
          })
        end
        let!(:store_1) do
          create(:store, payment_methods: [
            payment_method_nil_display,
            payment_method_both_display,
            payment_method_front_display,
            payment_method_back_display
          ])
        end

        subject { Spree::PaymentMethod.available_to_store( store_1 ).available_to_users.available_to_admin }

        it { is_expected.to contain_exactly(payment_method_both_display, payment_method_nil_display) }

        context "when the store has no payment methods" do
          subject { Spree::PaymentMethod.available_to_store(store_without_payment_methods) }
          let!(:store_without_payment_methods) do
            create(:store, payment_methods: [])
          end

          it "returns all payment methods" do
            expect(subject.all.size).to eq(5)
          end

          it "is further scopeable for admin availability" do
            expect(subject.available_to_admin).not_to include(payment_method_front_display)
          end

          it "is further scopeable for users availability" do
            expect(subject.available_to_users).not_to include(payment_method_back_display)
          end
        end
      end
    end

    context "when searching for payment methods available to users" do
      subject { Spree::PaymentMethod.available_to_users }

      it { is_expected.to contain_exactly(payment_method_front_display, payment_method_both_display, payment_method_nil_display) }
    end

    context "when searching for payment methods available to admin" do
      subject { Spree::PaymentMethod.available_to_admin }

      it { is_expected.to contain_exactly(payment_method_back_display, payment_method_both_display, payment_method_nil_display) }
    end

    context "when searching for payment methods available to a store" do
      subject { Spree::PaymentMethod.available_to_store(store) }

      context "when the store is nil" do
        let(:store) { nil }
        it "raises an argument error" do
          expect { subject }.to raise_error(ArgumentError, "You must provide a store")
        end
      end

      context "when the store exists" do
        let(:store) { create(:store, payment_methods: [payment_method_back_display]) }
        it { is_expected.to contain_exactly(payment_method_back_display) }
      end
    end
  end

  describe ".available" do
    it "should have 4 total methods" do
      expect(Spree::PaymentMethod.all.size).to eq(4)
    end

    it "should return all methods available to front-end/back-end when no parameter is passed" do
      Spree::Deprecation.silence do
        expect(Spree::PaymentMethod.available.size).to eq(2)
      end
    end

    it "should return all methods available to front-end/back-end when passed :both" do
      Spree::Deprecation.silence do
        expect(Spree::PaymentMethod.available(:both).size).to eq(2)
      end
    end

    it "should return all methods available to front-end when passed :front_end" do
      Spree::Deprecation.silence do
        expect(Spree::PaymentMethod.available(:front_end).size).to eq(3)
      end
    end

    it "should return all methods available to back-end when passed :back_end" do
      Spree::Deprecation.silence do
        expect(Spree::PaymentMethod.available(:back_end).size).to eq(3)
      end
    end

    context 'with stores' do
      let!(:store_1) do
        create(:store,
          payment_methods: [
            payment_method_nil_display,
            payment_method_both_display,
            payment_method_front_display,
            payment_method_back_display
          ])
      end

      let!(:store_2) do
        create(:store, payment_methods: [store_2_payment_method])
      end

      let!(:store_3) { create(:store) }

      let!(:store_2_payment_method) { create(:payment_method, active: true) }
      let!(:no_store_payment_method) { create(:payment_method, active: true) }

      context 'when the store is specified' do
        context 'when the store has payment methods' do
          it 'finds the payment methods for the store' do
            Spree::Deprecation.silence do
              expect(Spree::PaymentMethod.available(:both, store: store_1)).to match_array(
                [payment_method_nil_display, payment_method_both_display]
              )
            end
          end
        end

        context "when store does not have payment_methods" do
          it "returns all matching payment methods regardless of store" do
            Spree::Deprecation.silence do
              expect(Spree::PaymentMethod.available(:both)).to match_array(
                [
                  payment_method_nil_display,
                  payment_method_both_display,
                  store_2_payment_method,
                  no_store_payment_method
                ]
              )
            end
          end
        end
      end

      context 'when the store is not specified' do
        it "returns all matching payment methods regardless of store" do
          Spree::Deprecation.silence do
            expect(Spree::PaymentMethod.available(:both)).to match_array(
              [
                payment_method_nil_display,
                payment_method_both_display,
                store_2_payment_method,
                no_store_payment_method
              ]
            )
          end
        end
      end
    end
  end

  describe '#auto_capture?' do
    class TestGateway < Spree::PaymentMethod::CreditCard
      def gateway_class
        Provider
      end
    end

    let(:gateway) { TestGateway.new }

    subject { gateway.auto_capture? }

    context 'when auto_capture is nil' do
      before(:each) do
        expect(Spree::Config).to receive('[]').with(:auto_capture).and_return(auto_capture)
      end

      context 'and when Spree::Config[:auto_capture] is false' do
        let(:auto_capture) { false }

        it 'should be false' do
          expect(gateway.auto_capture).to be_nil
          expect(subject).to be false
        end
      end

      context 'and when Spree::Config[:auto_capture] is true' do
        let(:auto_capture) { true }

        it 'should be true' do
          expect(gateway.auto_capture).to be_nil
          expect(subject).to be true
        end
      end
    end

    context 'when auto_capture is not nil' do
      before(:each) do
        gateway.auto_capture = auto_capture
      end

      context 'and is true' do
        let(:auto_capture) { true }

        it 'should be true' do
          expect(subject).to be true
        end
      end

      context 'and is false' do
        let(:auto_capture) { false }

        it 'should be true' do
          expect(subject).to be false
        end
      end
    end
  end

  describe "display_on=" do
    around do |example|
      Spree::Deprecation.silence do
        example.run
      end
    end
    let(:payment) { described_class.new(display_on: display_on) }

    context 'with empty string' do
      let(:display_on) { "" }

      it "should be available to admins" do
        expect(payment.available_to_admin).to be true
      end

      it "should be available to users" do
        expect(payment.available_to_users).to be true
      end

      it "should have the same value for display_on" do
        expect(payment.display_on).to eq ""
      end
    end

    context 'with "back_end"' do
      let(:display_on) { "back_end" }

      it "should be available to admins" do
        expect(payment.available_to_admin).to be true
      end

      it "should not be available to users" do
        expect(payment.available_to_users).to be false
      end

      it "should have the same value for display_on" do
        expect(payment.display_on).to eq "back_end"
      end
    end

    context 'with "front_end"' do
      let(:display_on) { "front_end" }

      it "should be available to admins" do
        expect(payment.available_to_admin).to be false
      end

      it "should not be available to users" do
        expect(payment.available_to_users).to be true
      end

      it "should have the same value for display_on" do
        expect(payment.display_on).to eq "front_end"
      end
    end

    context 'with any other string' do
      let(:display_on) { "foobar" }

      it "should be available to admins" do
        expect(payment.available_to_admin).to be false
      end

      it "should not be available to users" do
        expect(payment.available_to_users).to be false
      end

      it "should have none for display_on" do
        expect(payment.display_on).to eq "none"
      end
    end
  end

  describe 'ActiveMerchant methods' do
    class PaymentGateway
      def initialize(options)
      end

      def authorize; 'authorize'; end

      def purchase; 'purchase'; end

      def capture; 'capture'; end

      def void; 'void'; end

      def credit; 'credit'; end
    end

    class TestPaymentMethod < Spree::PaymentMethod
      def gateway_class
        PaymentGateway
      end
    end

    let(:payment_method) { TestPaymentMethod.new }

    it "passes through authorize" do
      expect(payment_method.authorize).to eq 'authorize'
    end

    it "passes through purchase" do
      expect(payment_method.purchase).to eq 'purchase'
    end

    it "passes through capture" do
      expect(payment_method.capture).to eq 'capture'
    end

    it "passes through void" do
      expect(payment_method.void).to eq 'void'
    end

    it "passes through credit" do
      expect(payment_method.credit).to eq 'credit'
    end
  end

  describe 'model_name.human' do
    context 'PaymentMethod itself' do
      it "returns i18n value" do
        expect(Spree::PaymentMethod.model_name.human).to eq('Payment Method')
      end
    end

    context 'A subclass with no i18n key' do
      let!(:klass) { stub_const("MyGem::SomeClass", Class.new(described_class)) }

      it "returns default humanized value" do
        expect(klass.model_name.human).to eq('Some class')
      end
    end
  end

  describe "::DISPLAY" do
    it "returns [:both, :front_end, :back_end]" do
      # Emits deprecation warning on first reference
      Spree::Deprecation.silence do
        expect(Spree::PaymentMethod::DISPLAY).to eq([:both, :front_end, :back_end])
      end

      # but not subsequent
      expect(Spree::PaymentMethod::DISPLAY).to eq([:both, :front_end, :back_end])
    end
  end
end
