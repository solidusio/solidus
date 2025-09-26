# frozen_string_literal: true

require "rails_helper"
require "action_mailer"

RSpec.describe Spree::OrderInventoryCancellationMailerSubscriber do
  let(:bus) { Omnes::Bus.new }

  before do
    bus.register(:order_short_shipped)

    described_class.new.subscribe_to(bus)
  end

  describe "on :order_short_shipped" do
    context "when order cancellation emails are enabled" do
      it "sends cancellation email" do
        order = create :order

        expect(Spree::OrderMailer)
          .to receive(:inventory_cancellation_email)
          .and_call_original

        bus.publish(:order_short_shipped, order:, inventory_units: [])
      end
    end

    context "when order cancellation emails are disabled", :silence_deprecations do
      around do |example|
        original_value = Spree::OrderCancellations.send_cancellation_mailer
        Spree::OrderCancellations.send_cancellation_mailer = false
        example.run
      ensure
        Spree::OrderCancellations.send_cancellation_mailer = original_value
      end

      it "does not send cancellation email" do
        order = create :order

        expect(Spree::OrderMailer).not_to receive(:inventory_cancellation_email)

        bus.publish(:order_short_shipped, order:, inventory_units: [])
      end
    end
  end
end
