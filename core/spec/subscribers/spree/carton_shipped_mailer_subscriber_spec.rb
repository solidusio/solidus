# frozen_string_literal: true

require 'rails_helper'
require 'action_mailer'

RSpec.describe Spree::CartonShippedMailerSubscriber do
  let(:bus) { Omnes::Bus.new }

  before do
    bus.register(:carton_shipped)

    described_class.new.subscribe_to(bus)
  end

  describe 'on :carton_shipped' do
    context "when the carton's stock location is not fulfillable" do
      it "does not send an email" do
        carton = create :carton,
          stock_location: create(:stock_location, fulfillable: false)

        expect(Spree::CartonMailer).not_to receive(:shipped_email)

        bus.publish(:carton_shipped, carton:)
      end
    end

    context "when the carton is configured to suppress mailers" do
      it "does not send an email" do
        carton = create :carton, suppress_email: true

        expect(Spree::CartonMailer).not_to receive(:shipped_email)

        bus.publish(:carton_shipped, carton:)
      end
    end

    context "when the carton shipped email should be sent" do
      it "sends an email" do
        carton = create :carton

        expect(Spree::CartonMailer)
          .to receive(:shipped_email).and_call_original.once

        bus.publish(:carton_shipped, carton:)
      end
    end
  end
end
