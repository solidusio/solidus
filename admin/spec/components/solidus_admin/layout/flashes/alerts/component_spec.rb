# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::Layout::Flashes::Alerts::Component, type: :component do
  let(:component) { described_class.new(alerts:) }

  context "when alerts passed as Hash" do
    let(:alerts) do
      {warning: {title: "Be careful", message: "Something fishy going on"}}
    end

    it "renders correctly" do
      render_inline(component)

      aggregate_failures do
        expect(page).to have_content("Be careful")
        expect(page).to have_content("Something fishy going on")
      end
    end
  end

  context "when alerts passed as String" do
    let(:alerts) { "Something fishy going on" }

    it "renders correctly" do
      render_inline(component)

      aggregate_failures do
        expect(page).to have_content("Caution")
        expect(page).to have_content("Something fishy going on")
      end
    end
  end

  describe "multiple alerts" do
    let(:alerts) do
      {
        warning: {title: "Be careful", message: "Something fishy going on"},
        success: {title: "It worked", message: "Nothing to worry about!"}
      }
    end

    it "renders correctly" do
      render_inline(component)

      aggregate_failures do
        expect(page).to have_content("Be careful")
        expect(page).to have_content("Something fishy going on")
        expect(page).to have_content("It worked")
        expect(page).to have_content("Nothing to worry about!")
      end
    end
  end
end
