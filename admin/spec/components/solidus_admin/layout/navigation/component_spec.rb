# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::Layout::Navigation::Component, type: :component do
  before { allow(vc_test_controller).to receive(:spree_current_user).and_return(build(:user)) }

  it "renders the overview preview" do
    render_preview(:overview)
  end

  it "renders the solidus logo" do
    component = described_class.new(
      store: build(:store),
      items: []
    )

    render_inline(component)

    expect(page).to have_css("img[src*='logo/solidus']")
  end

  it "renders the store link" do
    component = described_class.new(
      store: build(:store, url: "https://example.com"),
      items: []
    )

    render_inline(component)

    expect(page).to have_content("https://example.com")
  end

  it "renders the account nav component" do
    account_component = mock_component do
      def call
        "account nav".html_safe
      end
    end
    component = described_class.new(
      store: build(:store),
      items: [],
    )
    allow(component).to receive(:component).and_call_original
    allow(component).to receive(:component).with('layout/navigation/account').and_return(account_component)

    render_inline(component)

    expect(page).to have_content("account nav")
  end
end
