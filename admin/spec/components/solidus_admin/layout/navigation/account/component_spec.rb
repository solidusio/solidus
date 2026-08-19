# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::Layout::Navigation::Account::Component, type: :component do
  let(:component) do
    described_class.new(
      user_label: "Alice",
      account_path: "/admin/account",
      logout_path: "/admin/logout",
      logout_method: :delete
    )
  end

  it "renders correctly" do
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

  describe "the timezone select" do
    it "is rendered when solidus_core provides the Timezone helper" do
      render_inline(component)

      expect(page).to have_css('select[name="solidus_timezone"]', visible: :any)
    end

    it "is omitted when solidus_core does not provide the Timezone helper" do
      hide_const("Spree::Core::ControllerHelpers::Timezone")

      render_inline(component)

      expect(page).to have_no_css('select[name="solidus_timezone"]', visible: :any)
    end
  end
end
