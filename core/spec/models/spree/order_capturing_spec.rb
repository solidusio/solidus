require 'spec_helper'

describe Spree::OrderCapturing do
  describe '#capture_payments' do
    subject { Spree::OrderCapturing.new(order, payment_methods).capture_payments }

    context "payment methods specified" do
      let!(:order) { create(:order, ship_address: create(:address)) }

      let!(:product) { create(:product, price: 10.00) }
      let!(:variant) do
        create(:variant, price: 10, product: product, track_inventory: false, tax_category: tax_rate.tax_category)
      end
      let!(:shipping_method) { create(:free_shipping_method) }
      let(:tax_rate) { create(:tax_rate, amount: 0.1, zone: create(:global_zone, name: "Some Tax Zone")) }
      let(:secondary_total) { 10.0 }
      let(:bogus_total) { order.total }

      before do
        order.contents.add(variant, 3)
        order.update!
        @secondary_bogus_payment = create(:payment, order: order, amount: secondary_total, payment_method: secondary_payment_method.create!(name: 'So bogus', environment: 'test'))
        @bogus_payment = create(:payment, order: order, amount: bogus_total)
        order.contents.advance
        order.complete!
        order.reload
      end

      context "payment method ordering" do
        let(:secondary_payment_method) { SecondaryBogusPaymentMethod }

        class SecondaryBogusPaymentMethod < Spree::Gateway::Bogus; end

        context "SecondaryBogusPaymentMethod payments are prioritized" do
          let(:payment_methods) { [SecondaryBogusPaymentMethod, Spree::Gateway::Bogus] }

          it "captures SecondaryBogusPaymentMethod payments first" do
            subject
            expect(@secondary_bogus_payment.reload.capture_events.sum(:amount)).to eq(10.0)
            expect(@bogus_payment.reload.capture_events.sum(:amount)).to eq(order.total - 10.0)
          end
        end

        context "Bogus payments are prioritized" do
          let(:payment_methods) { [Spree::Gateway::Bogus, SecondaryBogusPaymentMethod] }

          it "captures Bogus payments first" do
            subject
            expect(@secondary_bogus_payment.reload.capture_events.sum(:amount)).to eq(0.0)
            expect(@bogus_payment.reload.capture_events.sum(:amount)).to eq(order.total)
          end
        end

        context "when the payment method ordering is configured" do
          subject { Spree::OrderCapturing.new(order, payment_methods).capture_payments }

          let(:payment_methods) { nil }

          before do
            allow(Spree::OrderCapturing).to receive(:sorted_payment_method_classes).and_return(
              [SecondaryBogusPaymentMethod, Spree::Gateway::Bogus]
            )
          end

          it "captures in the order specified" do
            subject
            expect(@secondary_bogus_payment.reload.capture_events.sum(:amount)).to eq(10.0)
            expect(@bogus_payment.reload.capture_events.sum(:amount)).to eq(order.total - 10.0)
          end
        end
      end

      context "when a payment is not needed to capture the entire order" do
        let(:bogus_total) { order.total }
        let(:secondary_payment_method) { SecondaryBogusPaymentMethod }
        let(:payment_methods) { [Spree::Gateway::Bogus, SecondaryBogusPaymentMethod] }

        it "captures for the order and voids the unused payment" do
          subject
          expect(order.reload.payment_state).to eq 'paid'
          expect(@secondary_bogus_payment.reload.state).to eq 'void'
        end
      end

      context "when there is an error processing a payment" do
        let(:secondary_payment_method) { ExceptionallyBogusPaymentMethod }
        let(:bogus_total) { order.total - 1 }
        let(:secondary_total) { 1 }
        let(:payment_methods) { [Spree::Gateway::Bogus, ExceptionallyBogusPaymentMethod] }

        class ExceptionallyBogusPaymentMethod < Spree::Gateway::Bogus
          def capture(*args)
            raise ActiveMerchant::ConnectionError
          end
        end

        it "raises an error and leaves the order in a reasonable state" do
          expect { subject }.to raise_error(Spree::Core::GatewayError)
          expect(order.payments.to_a.sum(&:uncaptured_amount)).to eq 1.0
        end
      end
    end
  end
end
