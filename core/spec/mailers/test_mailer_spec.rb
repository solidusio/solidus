# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::TestMailer, type: :mailer do
  let(:user) { create(:user) }

  describe '#test_email' do
    subject { described_class.test_email('test@example.com') }

    it "is deprecated" do
      expect(Spree::Deprecation).to receive(:warn).
        with(/^Spree::TestMailer has been deprecated and will be removed/, any_args)

      test_email = subject
      expect(test_email.to).to eq(['test@example.com'])
    end
  end
end
