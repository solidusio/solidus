require 'spec_helper'
require 'email_spec'

describe Spree::TestMailer, :type => :mailer do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  let(:user) { create(:user) }

  it "confirm_email accepts a user id as an alternative to a User object" do
    expect {
      test_email = Spree::TestMailer.test_email('test@example.com')
    }.not_to raise_error
  end
end
