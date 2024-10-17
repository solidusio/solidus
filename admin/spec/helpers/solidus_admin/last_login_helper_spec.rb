# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::LastLoginHelper, type: :helper do
  describe "#last_login" do
    let(:user) { double("User") }

    context "when user has never logged in" do
      it "returns 'Never'" do
        allow(user).to receive(:last_sign_in_at).and_return(nil)

        expect(helper.last_login(user)).to eq("Never")
      end
    end

    context "when user has logged in before" do
      it "returns the time ago since the last login, capitalized" do
        last_sign_in_time = 2.days.ago
        allow(user).to receive(:last_sign_in_at).and_return(last_sign_in_time)

        expect(helper)
          .to receive(:time_ago_in_words)
            .with(last_sign_in_time)
            .and_return("2 days")

        expect(helper.last_login(user)).to eq("2 days ago")
      end
    end
  end
end
