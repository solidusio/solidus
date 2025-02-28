# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::UI::Button::Component, type: :component do
  it "renders previews" do
    render_preview(:playground)
    render_preview(:overview)
    render_preview(:group)
  end

  describe ".back" do
    let(:component) { described_class.back(path: "/index") }

    it "renders Back button" do
      render_inline(component)
      expect(page).to have_link(href: '/index', title: 'Back')
    end
  end

  describe ".discard" do
    let(:component) { described_class.discard(path: "/index") }

    it "renders Discard button" do
      render_inline(component)
      expect(page).to have_link(href: '/index')
      expect(page).to have_content("Discard")
    end
  end

  describe ".save" do
    let(:component) { described_class.save }

    it "renders Save button" do
      render_inline(component)
      expect(page).to have_button("Save")
    end
  end
end
