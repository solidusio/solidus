# frozen_string_literal: true

require 'rails_helper'
require 'action_mailer'

RSpec.describe Spree::OrderMailerSubscriber do
  let(:bus) { Omnes::Bus.new }

  before do
    bus.register(:order_finalized)

    described_class.new.subscribe_to(bus)
  end

  describe 'on :on_order_finalized' do
    it 'sends confirmation email' do
      order = create(:order, confirmation_delivered: false)

      expect(Spree::OrderMailer).to receive(:confirm_email).and_call_original

      bus.publish(:order_finalized, order:)
    end

    it 'marks the order as having the confirmation email delivered' do
      order = create(:order, confirmation_delivered: false)

      bus.publish(:order_finalized, order:)

      expect(order.confirmation_delivered).to be(true)
    end

    it "doesn't send confirmation email if already sent" do
      order = build(:order, confirmation_delivered: true)

      expect(Spree::OrderMailer).not_to receive(:confirm_email)

      bus.publish(:order_finalized, order:)
    end
  end

  describe "#send_reimbursement_email" do
    subject { described_class.new.send_reimbursement_email({}) }

    it "results in a deprecation warning" do
      if ENV["SOLIDUS_RAISE_DEPRECATIONS"]
        expect { subject }.to raise_error(ActiveSupport::DeprecationException)
      else
        expect(subject).to eq nil
      end
    end
  end
end
