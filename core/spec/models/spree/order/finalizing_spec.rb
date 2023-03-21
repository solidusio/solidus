# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Order, type: :model do
  context "#complete!" do
    let(:order) { create(:order_ready_to_complete) }

    it "should set completed_at" do
      expect { order.complete! }.to change { order.completed_at }
    end

    it "should sell inventory units" do
      inventory_unit = order.shipments.first.inventory_units.first

      order.payments.map(&:complete!)

      expect { order.complete! }.to change { inventory_unit.reload.pending }.from(true).to(false)
    end

    it "should change the shipment state to ready if order is paid" do
      order.payments.map(&:complete!)

      expect { order.complete! }.to change { order.shipments.first.state }.from('pending').to('ready')
    end

    it "should freeze all adjustments" do
      adjustment = create(:adjustment, order: order)

      expect { order.complete! }.to change { adjustment.reload.finalized }.from(false).to(true)
    end

    context "order is considered risky" do
      before do
        allow(order).to receive_messages is_risky?: true
      end

      context "and order is approved" do
        before do
          allow(order).to receive_messages approved?: true
        end

        it "should leave order in complete state" do
          order.complete!

          expect(order.state).to eq 'complete'
        end
      end
    end

    context "order is not considered risky" do
      before do
        allow(order).to receive_messages is_risky?: false
      end

      it "should set completed_at" do
        order.complete!

        expect(order.completed_at).to be_present
      end
    end

    context 'with event notifications' do
      it 'sends an email' do
        expect(Spree::Config.order_mailer_class).to receive(:confirm_email).and_call_original

        order.complete!
      end

      it 'marks the order as confirmation_delivered' do
        expect do
          order.complete!
        end.to change(order, :confirmation_delivered).to true
      end

      it 'sends the email' do
        expect(Spree::Config.order_mailer_class).to receive(:confirm_email).and_call_original

        order.complete!
      end

      it "doesn't send duplicate confirmation emails" do
        order.update(confirmation_delivered: true)

        expect(Spree::OrderMailer).not_to receive(:confirm_email)

        order.complete!
      end

      if Spree::Config.use_legacy_events
        # These specs show how notifications can be removed, one at a time or
        # all the ones set by MailerSubscriber module
        context 'when removing the default email notification subscription' do
          before do
            Spree::MailerSubscriber.deactivate(:order_finalized)
          end

          after do
            Spree::MailerSubscriber.activate
          end

          it 'does not send the email' do
            expect(Spree::Config.order_mailer_class).not_to receive(:confirm_email)

            order.complete!
          end
        end

        context 'when removing all the email notification subscriptions' do
          before do
            Spree::MailerSubscriber.deactivate
          end

          after do
            Spree::MailerSubscriber.activate
          end

          it 'does not send the email' do
            expect(Spree::Config.order_mailer_class).not_to receive(:confirm_email)

            order.complete!
          end
        end
      end
    end
  end
end
