# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::Products::Form::FilenameInfo::Component, type: :component do
  context "with a short filename" do
    let(:filename) { "small.png" }

    it "renders the full filename" do
      render_inline(described_class.new(filename:))

      expect(page).to have_content("small")
    end

    it "does not show the toggletip for short filenames" do
      render_inline(described_class.new(filename:))

      expect(page).not_to have_css('[role="tooltip"]')
    end

    it "renders the uppercase file extension" do
      render_inline(described_class.new(filename:))

      expect(page).to have_content("PNG")
    end
  end

  context "with a long filename" do
    let(:filename) { "this-is-a-very-long-filename-that-needs-truncation.jpg" }

    it "renders a truncated filename with a tooltip" do
      render_inline(described_class.new(filename:))

      expect(page).to have_content("this…ion")
      expect(page).to have_content("this-is-a-very-long-filename-that-needs-truncation.jpg")
    end

    it "shows the toggletip for long filenames" do
      render_inline(described_class.new(filename:))

      expect(page).to have_css("details")
      expect(page).to have_css("summary")
    end

    it "has the full filename in the toggletip bubble" do
      render_inline(described_class.new(filename:))

      expect(page).to have_content("this-is-a-very-long-filename-that-needs-truncation.jpg")
    end

    it "renders the uppercase file extension" do
      render_inline(described_class.new(filename:))

      expect(page).to have_content("JPG")
    end
  end

  context "with special characters in filename" do
    let(:filename) { "my-image (1).jpg" }

    it "renders the filename with special characters" do
      render_inline(described_class.new(filename:))

      expect(page).to have_content("my-image (1)")
      expect(page).to have_content("JPG")
    end
  end
end
