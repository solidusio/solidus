# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Core::Engine do
  it 'loads engine and app previews' do
    expect(ActionMailer::Preview.all).to match_array([
      TestMailerPreview,
      Spree::MailerPreviews::ReimbursementPreview,
      Spree::MailerPreviews::OrderPreview,
      Spree::MailerPreviews::CartonPreview,
    ])
  end

  context "warns about deprecation" do
    before do
      Rails::Railtie.initializers.each(&:run)
      stub_spree_preferences(associate_user_in_authentication_extension: false)
    end
    it "Order#associate_user" do
      expect(Spree::Deprecation).to receive(:warn)
      #with(/^Order#associate_user is deprecated/, any_args)
    end
  end
end
