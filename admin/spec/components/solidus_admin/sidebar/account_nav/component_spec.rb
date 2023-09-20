# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::Sidebar::AccountNav::Component, type: :component do
  it "renders the overview preview" do
    render_preview(:overview)
  end

  it "renders correctly" do
    component = described_class.new(
      user_label: "Alice",
      account_path: "/admin/account",
      logout_path: "/admin/logout",
      logout_method: :delete,
    )

    render_inline(component)

    aggregate_failures do
      expect(page).to have_content("Alice")

      # Links are hidden within a <details> element
      expect(page).to have_link("Account", href: "/admin/account", visible: :any)
      within('form[action="/admin/logout"]') do
        expect(page).to have_button("Logout", visible: :any)
        expect(page).to have_css('input[type="hidden"][name="_method"][value="delete"]')
      end
    end
  end
end
