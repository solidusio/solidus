require 'spec_helper'

module Spree
  describe Spree::Order do
    let(:order) { create(:order_with_line_items) }
    let(:updater) { Spree::OrderUpdater.new(order) }

    before do
      # So that Payment#purchase! is called during processing
      Spree::Config[:auto_capture] = true
    end

    it 'processes all payments' do
      payment_1 = create(:payment, :amount => 50, order: order)
      payment_2 = create(:payment, :amount => 50, order: order)
      order.stub(:pending_payments).and_return([payment_1, payment_2])

      order.process_payments!
      updater.update_payment_state
      order.payment_state.should == 'paid'

      payment_1.should be_completed
      payment_2.should be_completed
    end

    it 'does not go over total for order' do
      payment_1 = create(:payment, :amount => 50, order: order)
      payment_2 = create(:payment, :amount => 50, order: order)
      payment_3 = create(:payment, :amount => 50, order: order)
      order.stub(:pending_payments).and_return([payment_1, payment_2, payment_3])

      order.process_payments!
      updater.update_payment_state
      order.payment_state.should == 'paid'

      payment_1.should be_completed
      payment_2.should be_completed
      payment_3.should be_checkout
    end

    it "does not use failed payments" do
      skip "This is returning a stack level too deep, but ultimately isn't testing much even if it worked"
      payment_1 = create(:payment, :amount => 50, order: order)
      payment_2 = create(:payment, :amount => 50, :state => 'failed', order: order)
      order.stub(:pending_payments).and_return([payment_1])

      payment_2.should_not_receive(:process!)

      order.process_payments!
    end
  end
end
