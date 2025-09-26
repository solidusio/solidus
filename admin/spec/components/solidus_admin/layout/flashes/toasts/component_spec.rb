# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::Layout::Flashes::Toasts::Component, type: :component do
  let(:component) { described_class.new(toasts:) }

  describe "error toast" do
    let(:toasts) { {error: "Some error"} }

    it "renders correctly" do
      render_inline(component)

      aggregate_failures do
        expect(page).to have_content("Some error")
        expect(page).to have_css(".bg-red-500")
      end
    end
  end

  describe "default toast" do
    let(:toasts) { {notice: "All good"} }

    it "renders correctly" do
      render_inline(component)

      aggregate_failures do
        expect(page).to have_content("All good")
        expect(page).to have_css(".bg-full-black")
      end
    end
  end
end
