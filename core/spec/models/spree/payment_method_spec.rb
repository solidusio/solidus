require 'spec_helper'

describe Spree::PaymentMethod, type: :model do
  describe ".available" do
    let!(:payment_method_nil_display)  { create(:payment_method, active: true, display_on: nil) }
    let!(:payment_method_both_display) { create(:payment_method, active: true, display_on: 'both') }
    let!(:payment_method_front_display){ create(:payment_method, active: true, display_on: 'front_end') }
    let!(:payment_method_back_display) { create(:payment_method, active: true, display_on: 'back_end') }

    it "should have 4 total methods" do
      expect(Spree::PaymentMethod.all.size).to eq(4)
    end

    it "should return all methods available to front-end/back-end when no parameter is passed" do
      expect(Spree::PaymentMethod.available.size).to eq(2)
    end

    it "should return all methods available to front-end/back-end when display_on = :both" do
      expect(Spree::PaymentMethod.available(:both).size).to eq(2)
    end

    it "should return all methods available to front-end when display_on = :front_end" do
      expect(Spree::PaymentMethod.available(:front_end).size).to eq(2)
    end

    it "should return all methods available to back-end when display_on = :back_end" do
      expect(Spree::PaymentMethod.available(:back_end).size).to eq(2)
    end

    context 'with stores' do
      let!(:store_1) do
        create(:store,
          payment_methods: [
            payment_method_nil_display,
            payment_method_both_display,
            payment_method_front_display,
            payment_method_back_display
          ]
        )
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
            expect(Spree::PaymentMethod.available(:both, store: store_1)).to match_array(
              [payment_method_nil_display, payment_method_both_display]
            )
          end
        end

        context "when store does not have payment_methods" do
          it "returns all matching payment methods regardless of store" do
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

      context 'when the store is not specified' do
        it "returns all matching payment methods regardless of store" do
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

  describe '#auto_capture?' do
    class TestGateway < Spree::Gateway
      def provider_class
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
end
