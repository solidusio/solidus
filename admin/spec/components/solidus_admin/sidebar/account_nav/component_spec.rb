# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::Sidebar::AccountNav::Component, type: :component do
  it "renders the overview preview" do
    render_preview(:overview)
  end

  it "renders link to the account" do
    component = described_class.new(
      account_path: "/admin/account"
    )

    render_inline(component)

    expect(page).to have_link("Account", href: "/admin/account", visible: :any)
  end

  it "renders link to logout" do
    component = described_class.new(
      logout_path: "/admin/logout"
    )

    render_inline(component)

    expect(page).to have_link("Logout", href: "/admin/logout", visible: :any)
  end

  it "renders user lanel" do
    component = described_class.new(
      user_label: "Alice"
    )

    render_inline(component)

    expect(page).to have_content("Alice")
  end
end
