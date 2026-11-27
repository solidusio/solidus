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
    it "shows an error when uploading an unsupported file type" do
      visit "/admin/products/test-product"

      expect(page).to have_content(/No images found/i)
      expect(page).to have_link("Add files")

      click_on "Add files"
      attach_file("image_attachment", File.join(
        Spree::Core::Engine.root, "lib/spree/testing_support/fixtures/file.txt"
      ), make_visible: true)

      expect(page).to have_css("dialog", visible: :visible)
      expect(page).to have_content("Upload failed")
      expect(page).to have_content("file.txt: Attachment is not an image")
      expect(page).to have_content("Add files")
      expect(page).to have_content("or drag and drop them here")
      expect(Spree::Image.where(viewable: product.master).count).to eq(0)
    end

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

      expect(page).to have_css("tbody tr", count: 2)

      expect(page).to have_css("tbody tr", text: "Featured", count: 1)

      second_row = page.all("tbody tr")[1]
      expect(second_row).not_to have_css('div[class*="bg-seafoam"]', text: "Featured")
    end
  end

  context "deleting a single image" do
    before do
      create :image, viewable: product.master
      create :image, viewable: product.master
      create :image, viewable: product.master
    end

    it "deletes a single selected image" do
      visit "/admin/products/test-product"

      image_id_to_delete = nil

      within_section "Media" do
        expect(find_all("tbody tr").count).to eq 3

        featured_image_checkbox =
          find("tbody tr", text: /Featured/i).find("input[type='checkbox']")
        image_id_to_delete = featured_image_checkbox.value
        featured_image_checkbox.check

        expect(page).to have_content("1 selected")

        click_on "Delete"
      end

      within "dialog" do
        click_on "Delete"
      end
      expect(page).to have_content "One image was successfully deleted."

      within_section "Media" do
        expect(find_all("tbody tr").count).to eq 2

        remaining_image_ids =
          find_all("tbody tr").map { |tr| tr.find("input[type='checkbox']").value }

        expect(remaining_image_ids).not_to include(image_id_to_delete)
      end

      expect(Spree::Image.where(viewable: product.master).count).to eq(2)
    end
  end

  context "deleting multiple images" do
    before do
      create :image, viewable: product.master
      create :image, viewable: product.master
      create :image, viewable: product.master
    end

    it "deletes multiple selected images" do
      visit "/admin/products/test-product"

      image_ids_to_delete = []

      within_section "Media" do
        expect(find_all("tbody tr").count).to eq 3

        # Select the first two images
        rows = find_all("tbody tr")
        rows.first(2).each do |row|
          checkbox = row.find("input[type='checkbox']")
          image_ids_to_delete << checkbox.value
          checkbox.check
        end

        expect(page).to have_content("2 selected")

        click_on "Delete"
      end

      within "dialog" do
        click_on "Delete"
      end
      expect(page).to have_content "2 images were successfully deleted."

      within_section "Media" do
        expect(find_all("tbody tr").count).to eq 1

        remaining_image_ids =
          find_all("tbody tr").map { |tr| tr.find("input[type='checkbox']").value }

        expect(remaining_image_ids).not_to include(image_ids_to_delete)
      end

      expect(Spree::Image.where(viewable: product.master).count).to eq(1)
    end
  end

  context "deleting all images" do
    before do
      create :image, viewable: product.master
      create :image, viewable: product.master
    end

    it "deletes all images using the header checkbox" do
      visit "/admin/products/test-product"

      within_section "Media" do
        expect(find_all("tbody tr").count).to eq 2

        find("thead input[type='checkbox']").check

        expect(page).to have_content("2 selected")

        click_on "Delete"
      end

      within "dialog" do
        click_on "Delete"
      end
      expect(page).to have_content "2 images were successfully deleted."

      within_section "Media" do
        expect(page).to have_content(/No images found/i)
      end

      expect(Spree::Image.where(viewable: product.master).count).to eq(0)
    end
  end

  context "reordering images" do
    before do
      create(:image, viewable: product.master, position: 1)
      create(:image, viewable: product.master, position: 2)
      create(:image, viewable: product.master, position: 3)
    end

    it "reorders images via drag and drop" do
      visit "/admin/products/test-product"

      within_section "Media" do
        rows = find_all("tbody tr")
        expect(rows.count).to eq 3

        initial_positions = rows.map { |row| row.find("input[type='checkbox']").value }
        first_image_id = initial_positions.first
        third_image_id = initial_positions.last

        first_image = Spree::Image.find(first_image_id)
        third_image = Spree::Image.find(third_image_id)
        expect(first_image.position).to eq(1)
        expect(third_image.position).to eq(3)

        third_row = rows.last
        first_row = rows.first
        draggable_handle = third_row.find(".handle")

        draggable_handle.drag_to(first_row)

        # Sorry for the sleep. There are no changes to the DOM that can
        # easily be asserted on.
        sleep 0.5

        third_image.reload
        first_image.reload
        expect(third_image.position).to eq(1)
        expect(first_image.position).to eq(2)
      end
    end

    it "updates the featured badge to the new first image after drag and drop" do
      visit "/admin/products/test-product"

      expect(page).to have_css("tbody tr", text: "Featured")

      rows = find_all("tbody tr")
      third_row = rows.last
      first_row = rows.first
      third_image_id = third_row.find("input[type='checkbox']").value
      draggable_handle = third_row.find(".handle")

      draggable_handle.drag_to(first_row)

      expect(page).to have_css("tbody tr:first-child", text: "Featured")
      expect(page).to have_css("tbody tr", text: "Featured", count: 1)
      expect(find("tbody tr:first-child input[type='checkbox']").value).to eq(third_image_id)
    end
  end

  context "editing an image" do
    before do
      create(:image, viewable: product.master, position: 1, alt: "Original alt text")
    end

    it "opens edit modal and updates alt text" do
      visit "/admin/products/test-product"

      within_section "Media" do
        click_on "Edit"
      end

      expect(page).to have_css("dialog", visible: :visible)
      expect(page).to have_content("Edit image")

      fill_in "Alternative Text", with: "New alt text"

      click_on "Update"

      expect(page).to have_content("Image was successfully updated.")

      image = Spree::Image.first
      expect(image.alt).to eq("New alt text")
    end

    it "cancels edit without saving" do
      visit "/admin/products/test-product"

      within_section "Media" do
        click_on "Edit"
      end

      expect(page).to have_css("dialog", visible: :visible)
      click_on "Cancel"

      expect(page).to have_no_css("dialog", visible: :visible)

      image = Spree::Image.first
      expect(image.alt).to eq("Original alt text")
    end
  end

  def within_section(heading, &block)
    section = find("h2", text: heading).ancestor("[data-controller='ui--panel']")
    within(section) do
      yield
    end
  end
end
