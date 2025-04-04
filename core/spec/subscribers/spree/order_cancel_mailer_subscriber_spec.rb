# frozen_string_literal: true

require 'rails_helper'
require 'action_mailer'

RSpec.describe Spree::OrderCancelMailerSubscriber do
  let(:bus) { Omnes::Bus.new }

  before do
    bus.register(:order_canceled)

    described_class.new.subscribe_to(bus)
  end

  describe 'on :order_canceled' do
    it 'sends cancellation email' do
      order = create :order

      expect(Spree::OrderMailer).to receive(:cancel_email).and_call_original

      bus.publish(:order_canceled, order:)
    end
  end
end
