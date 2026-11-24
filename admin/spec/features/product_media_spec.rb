# frozen_string_literal: true

require "spec_helper"

describe "Product Media Management", :js, type: :feature do
  before do
    allow(SolidusAdmin::Config).to receive(:enable_alpha_features?) { true }
    sign_in create(:admin_user, email: "admin@example.com")
    @product = create(:product, name: "Test Product", slug: "test-product")
  end

  let(:product) { @product }

  context "uploading images" do
    it "uploads a single image and shows it in the media table" do
      visit "/admin/products/test-product"

      expect(page).to have_content(/No images found/i)
      expect(page).to have_link("Add files")

      click_on "Add files"
      attach_file("image_attachment", File.join(
        Spree::Core::Engine.root, "lib/spree/testing_support/fixtures/blank.jpg"
      ), make_visible: true)

      expect(page).to have_content("Test Product")
      expect(page).not_to have_css("dialog")
      expect(page).to have_content("blank")
      expect(Spree::Image.where(viewable: product.master).count).to eq(1)

      product.master.images.first
      first_image_row = find("tr", text: "blank")
      expect(first_image_row).to have_css('div[class*="bg-seafoam"]', text: "Featured")
    end
  end

  context "viewing existing images" do
    before do
      create(:image, viewable: product.master)
      create(:image, viewable: product.master)
    end

    it "displays existing images with correct featured status" do
      visit "/admin/products/test-product"

      # Verify images are displayed in the table
      expect(page).to have_css("tbody tr", count: 2)

      # Verify only the first image has the featured badge
      expect(page).to have_css("tr", text: "Featured", count: 1)

      # Verify the second row does not have the featured badge
      second_row = page.all("tbody tr")[1]
      expect(second_row).not_to have_css('div[class*="bg-seafoam"]', text: "Featured")
    end
  end
end
