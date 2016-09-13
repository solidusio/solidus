require 'spec_helper'

describe Spree::OrderCapturing do
  describe '#capture_payments' do
    subject { Spree::OrderCapturing.new(order, payment_methods).capture_payments }

    # Regression for https://github.com/solidusio/solidus/pull/407
    # See also https://github.com/solidusio/solidus/pull/1406
    context "updating the order" do
      let(:order) { create :completed_order_with_totals }
      let(:payment_methods) { [] }
      let!(:payment) { create(:payment, order: order, amount: order.total) }
      let(:changes_spy) { spy('changes_spy') }

      before do
        payment.pend!

        allow_any_instance_of(Spree::Order).to receive(:thingamajig) do |order|
          changes_spy.change_callback_occured if order.changes.any?
        end

        @update_hooks = Spree::Order.update_hooks.dup
        Spree::Order.register_update_hook :thingamajig
      end

      after do
        Spree::Order.update_hooks = @update_hooks
      end

      it "keeps the order up to date when updating and only changes it once" do
        subject
        expect(changes_spy).to have_received(:change_callback_occured).once
      end
    end

    context "payment methods specified" do
      let!(:order) { create(:order, ship_address: create(:address)) }

      let!(:product) { create(:product, price: 10.00) }
      let!(:variant) do
        create(:variant, price: 10, product: product, track_inventory: false, tax_category: tax_rate.tax_category)
      end
      let!(:shipping_method) { create(:free_shipping_method) }
      let(:tax_rate) { create(:tax_rate, amount: 0.1, zone: create(:global_zone, name: "Some Tax Zone")) }
      let(:secondary_total) { 10.0 }
      let(:bogus_total) { order.total - secondary_total }

      before do
        order.contents.add(variant, 3)
        order.update!
        @secondary_bogus_payment = create(:payment, order: order, amount: secondary_total, payment_method: secondary_payment_method.create!(name: 'So bogus'))
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
            @bogus_payment.update!(amount: bogus_total + 100)
            subject
            expect(@secondary_bogus_payment.reload.capture_events.sum(:amount)).to eq(10.0)
            expect(@bogus_payment.reload.capture_events.sum(:amount)).to eq(order.total - 10.0)
          end
        end

        context "Bogus payments are prioritized" do
          let(:payment_methods) { [Spree::Gateway::Bogus, SecondaryBogusPaymentMethod] }

          it "captures Bogus payments first" do
            @secondary_bogus_payment.update!(amount: secondary_total + 100)
            subject
            expect(@bogus_payment.reload.capture_events.sum(:amount)).to eq(order.total - 10.0)
            expect(@secondary_bogus_payment.reload.capture_events.sum(:amount)).to eq(10.0)
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
        let(:secondary_payment_method) { SecondaryBogusPaymentMethod }
        let(:payment_methods) { [Spree::Gateway::Bogus, SecondaryBogusPaymentMethod] }

        before do
          @bogus_payment.update!(amount: order.total)
        end

        context "when void_unused_payments is true" do
          before { allow(Spree::OrderCapturing).to receive(:void_unused_payments).and_return(true) }

          it "captures for the order and voids the unused payment" do
            subject
            expect(order.reload.payment_state).to eq 'paid'
            expect(@secondary_bogus_payment.reload.state).to eq 'void'
          end
        end

        context "when void_unused_payments is false" do
          it "captures for the order and leaves the unused payment in a pending state" do
            subject
            expect(order.reload.payment_state).to eq 'paid'
            expect(@secondary_bogus_payment.reload.state).to eq 'pending'
          end
        end
      end

      context "when there is an error processing a payment" do
        let(:secondary_payment_method) { ExceptionallyBogusPaymentMethod }
        let(:bogus_total) { order.total - 1 }
        let(:secondary_total) { 1 }
        let(:payment_methods) { [Spree::Gateway::Bogus, ExceptionallyBogusPaymentMethod] }

        class ExceptionallyBogusPaymentMethod < Spree::Gateway::Bogus
          def capture(*_args)
            raise ActiveMerchant::ConnectionError.new("foo", nil)
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
