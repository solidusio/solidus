# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solidus::TestMailer, type: :mailer do
  let(:user) { create(:user) }

  it "confirm_email accepts a user id as an alternative to a User object" do
    Solidus::Deprecation.silence do
      Solidus::TestMailer.test_email('test@example.com')
    end
  end
end
