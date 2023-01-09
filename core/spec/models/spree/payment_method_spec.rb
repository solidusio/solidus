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

  describe "preferences" do
    subject { described_class.new.preferences }

    it { is_expected.to be_a(Hash) }
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

  describe '#auto_capture?' do
    let(:gateway) do
      gateway_class = Class.new(Spree::PaymentMethod::CreditCard) do
        def gateway_class
          Provider
        end
      end

      gateway_class.new
    end

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

  describe 'ActiveMerchant methods' do
    let(:payment_method) do
      payment_method_class = Class.new(Spree::PaymentMethod) do
        def gateway_class
          Class.new do
            def initialize(options)
            end

            def authorize; 'authorize'; end

            def purchase; 'purchase'; end

            def capture; 'capture'; end

            def void; 'void'; end

            def credit; 'credit'; end
          end
        end
      end

      payment_method_class.new
    end

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

  describe "#find_sti_class" do
    context "with an unexisting type" do
      context "while retrieving records" do
        let!(:unsupported_payment_method) { create(:payment_method, type: 'UnsupportedPaymentMethod') }

        it "raises an UnsupportedPaymentMethod error" do
          expect { Spree::PaymentMethod.all.to_json }
            .to raise_error(
              Spree::PaymentMethod::UnsupportedPaymentMethod,
              /Found invalid payment type 'UnsupportedPaymentMethod'/
            )
        end
      end
    end
  end
end
