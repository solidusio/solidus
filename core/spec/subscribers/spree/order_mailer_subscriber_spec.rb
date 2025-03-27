# frozen_string_literal: true

require 'rails_helper'
require 'action_mailer'

RSpec.describe Spree::OrderMailerSubscriber do
  let(:bus) { Omnes::Bus.new }

  before do
    bus.register(:order_finalized)

    described_class.new.subscribe_to(bus)
  end

  describe "#send_confirmation_email" do
    subject { described_class.new.send_confirmation_email({}) }

    it "results in a deprecation warning" do
      if ENV["SOLIDUS_RAISE_DEPRECATIONS"]
        expect { subject }.to raise_error(ActiveSupport::DeprecationException)
      else
        expect(subject).to eq nil
      end
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
