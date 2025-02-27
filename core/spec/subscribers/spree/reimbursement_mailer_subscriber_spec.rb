# frozen_string_literal: true

require 'rails_helper'
require 'action_mailer'

RSpec.describe Spree::ReimbursementMailerSubscriber do
  let(:bus) { Omnes::Bus.new }

  before do
    bus.register(:reimbursement_reimbursed)

    described_class.new.subscribe_to(bus)
  end

  describe 'on :reimbursement_reimbursed' do
    it 'sends reimbursement email' do
      reimbursement = build(:reimbursement)

      expect(Spree::ReimbursementMailer).to receive(:reimbursement_email).and_call_original

      bus.publish(:reimbursement_reimbursed, reimbursement:)
    end
  end
end
