# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Order, type: :model do
  context "#finalize!" do
    let(:order) { create(:order_ready_to_complete) }

    before do
      order.update_column :state, 'complete'
    end

    it "should set completed_at" do
      expect(order).to receive(:touch).with(:completed_at)
      order.finalize!
    end

    it "should sell inventory units" do
      order.shipments.each do |shipment|
        expect(shipment).to receive(:update_state)
        expect(shipment).to receive(:finalize!)
      end
      order.finalize!
    end

    it "should change the shipment state to ready if order is paid" do
      allow(order).to receive_messages(paid?: true, complete?: true)
      order.finalize!
      order.reload # reload so we're sure the changes are persisted
      expect(order.shipment_state).to eq('ready')
    end

    it "should send an order confirmation email" do
      mail_message = double "Mail::Message"
      expect(Spree::OrderMailer).to receive(:confirm_email).with(order).and_return mail_message
      expect(mail_message).to receive :deliver_later
      order.finalize!
    end

    it "sets confirmation delivered when finalizing" do
      expect(order.confirmation_delivered?).to be false
      order.finalize!
      expect(order.confirmation_delivered?).to be true
    end

    it "should not send duplicate confirmation emails" do
      order.update(confirmation_delivered: true)
      expect(Spree::OrderMailer).not_to receive(:confirm_email)
      order.finalize!
    end

    it "should freeze all adjustments" do
      # Stub this method as it's called due to a callback
      # and it's irrelevant to this test
      allow(Spree::OrderMailer).to receive_message_chain :confirm_email, :deliver_later
      adjustments = [double]
      expect(order).to receive(:all_adjustments).and_return(adjustments)
      adjustments.each do |adj|
        expect(adj).to receive(:finalize!)
      end
      order.finalize!
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
          order.finalize!
          expect(order.state).to eq 'complete'
        end
      end
    end

    context "order is not considered risky" do
      before do
        allow(order).to receive_messages is_risky?: false
      end

      it "should set completed_at" do
        order.finalize!
        expect(order.completed_at).to be_present
      end
    end
  end
end
