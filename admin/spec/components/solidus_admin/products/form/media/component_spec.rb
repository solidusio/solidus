# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::Products::Form::Media::Component, type: :component do
  let(:product) { create(:product) }
  let(:form) { ActionView::Helpers::FormBuilder.new("product", product, self, {}) }
  let(:component) { described_class.new(form:) }

  context "with no images" do
    it "renders a no images message" do
      render_inline(component)

      expect(page).to have_content(/No images found/i)
    end

    it "renders the add files header action" do
      render_inline(component)

      expect(page).to have_link("Add files")
    end
  end

  context "with images" do
    let!(:first_image) { create(:image, viewable: product.master, position: 1) }
    let!(:second_image) { create(:image, viewable: product.master, position: 2) }

    before do
      allow(product.master).to receive(:images).and_return([first_image, second_image])
    end

    it "renders the media table" do
      render_inline(component)

      expect(page).to have_content(first_image.attachment.filename.to_s)
      expect(page).to have_content(second_image.attachment.filename.to_s)
    end

    it "renders the featured badge for the first image (position 1)" do
      render_inline(component)

      expect(page).to have_selector("tr", text: first_image.attachment.filename.to_s)
      expect(page).to have_selector(%(td div[class*="bg-seafoam"]), text: "Featured")
    end

    it "does not render featured badge for non-first images", :aggregate_failures do
      render_inline(component)

      expect(page).to have_selector("tr", text: second_image.attachment.filename.to_s)

      # The second image row should not have the featured badge.
      expect(page)
        .not_to have_selector(
          "tr",
          text: /#{Regexp.escape(second_image.attachment.filename.to_s)}.*Featured/
        )
    end

    it "renders image thumbnails" do
      render_inline(component)

      expect(page).to have_selector("td")
    end

    it "renders date added column" do
      render_inline(component)

      expect(page).to have_content(first_image.created_at.strftime("%b %d, %Y"))
    end

    it "renders size column" do
      render_inline(component)

      expect(page).to have_selector("td", text: /\d/)
    end

    it "renders filename info component" do
      render_inline(component)

      expect(page).to have_content(File.basename(first_image.attachment.filename.to_s, ".*"))
    end
  end

  context "with image that has no attachment" do
    let!(:orphan_image) { create(:image, viewable: product.master, position: 1) }

    before do
      allow(orphan_image.attachment).to receive(:attached?).and_return(false)
      allow(product.master).to receive(:images).and_return([orphan_image])
    end

    it "renders a placeholder for missing images" do
      render_inline(component)

      expect(page).to have_selector("td div.bg-gray-200")
    end
  end

  describe "#human_size" do
    it "converts bytes to human readable format" do
      render_inline(component)

      expect(component.human_size(1024)).to eq("1 KB")
      expect(component.human_size(1_048_576)).to eq("1 MB")
    end
  end
end
