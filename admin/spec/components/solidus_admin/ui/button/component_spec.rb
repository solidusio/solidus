# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::UI::Button::Component, type: :component do
  it "renders previews" do
    render_preview(:playground)
    render_preview(:overview)
    render_preview(:group)
  end

  describe ".submit" do
    let(:component) { described_class.submit(resource:) }

    context "for a new resource" do
      let(:resource) { build(:zone) }

      it "renders correct submit button" do
        render_inline(component)
        expect(page).to have_content("Add Zone")
      end
    end

    context "for an existing resource" do
      let(:resource) { create(:zone) }

      it "renders correct submit button" do
        render_inline(component)
        expect(page).to have_content("Update Zone")
      end
    end
  end
end
