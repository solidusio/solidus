# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Core::Engine do
  it "loads engine and app previews" do
    expect(ActionMailer::Preview.all).to match_array([
      TestMailerPreview,
      Spree::MailerPreviews::ReimbursementPreview,
      Spree::MailerPreviews::OrderPreview,
      Spree::MailerPreviews::CartonPreview
    ])
  end
end
