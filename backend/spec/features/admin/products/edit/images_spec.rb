require 'spec_helper'

describe "Product Images", type: :feature do
  stub_authorization!

  let(:file_path) { Rails.root + "../../spec/support/ror_ringer.jpeg" }
  let(:product)   { create(:product) }

  before do
    # Ensure attachment style keys are symbolized before running all tests
    # Otherwise this would result in this error:
    # undefined method `processors' for \"48x48>\
    Spree::Image.attachment_definitions[:attachment][:styles].symbolize_keys!
  end

  context "uploading, editing, and deleting an image", js: true do
    it "should allow an admin to upload and edit an image for a product" do
      Spree::Image.attachment_definitions[:attachment].delete :storage

      create(:product)

      visit spree.admin_path
      click_nav "Products"
      click_icon(:edit)
      click_link "Images"
      click_link "new_image_link"
      within_fieldset 'New Image' do
        attach_file('image_attachment', file_path)
      end
      click_button "Update"
      expect(page).to have_content("successfully created!")

      # Icons are hidden, so hover to have them pop-up
      find('tbody > tr').hover
      within_row(1) do
        within ".actions" do
          click_icon :edit
        end
      end

      fill_in "image_alt", with: "ruby on rails t-shirt"
      click_button "Update"

      expect(page).to have_content "successfully updated!"
      expect(page).to have_field "image[alt]", with: "ruby on rails t-shirt"

      find('tbody > tr').hover
      accept_alert do
        click_icon :trash
      end
      expect(page).not_to have_field "image[alt]", with: "ruby on rails t-shirt"
    end
  end

  context 'Via the upload zone', js: true do
    before do
      create(:variant, product: product)
    end

    it "uploads an image with ajax and appends it to the images table" do
      visit spree.admin_product_images_path(product)
      expect(page).to have_content("No images found")

      within_fieldset 'Upload Images' do
        # Can also pass multiple files in the array, but SQLite gives a deadlock on insert
        attach_file('image_attachment', [file_path], visible: false)
      end

      expect(page).not_to have_content("No images found")

      within("table.index") do
        expect(page).to have_css "tbody tr", count: 1

        within("tbody") do
          expect(page).to have_xpath "//img[contains(@src,'ror_ringer')]"
          expect(page).to have_select "image_viewable_id", selected: "All"
        end
      end

      expect(Spree::Image.last.viewable).to eq(product.master)
    end
  end

  context "Visiting the images index", js: true do
    let!(:variant) { FactoryGirl.create :variant, sku: "TEST" }
    let!(:image) { variant.images.create!(attachment: File.open(file_path)) }

    it "allows admins to update images without leaving the page", js: true do
      visit spree.admin_product_images_path(variant.product)

      within("#spree_image_#{image.id}") do
        expect(page).to have_select('image_viewable_id', selected: "TEST Size: S")

        # Update the image's alt text and variant
        fill_in 'image[alt]', with: 'Alternative description'
        select "All", from: "image_viewable_id"
        click_icon :check

        expect(page).to have_select "image_viewable_id", selected: "All"
        expect(page).to have_field "image[alt]", with: "Alternative description"
      end

      expect(page).to have_content "Updated successfully"

      within("#spree_image_#{image.id}") do
        expect(page).to have_select "image_viewable_id", selected: "All"
        expect(page).to have_field "image[alt]", with: "Alternative description"
      end
    end
  end

  it "should not see variant column when product has no variants" do
    product = create(:product)
    product.images.create!(attachment: File.open(file_path))
    visit spree.admin_product_images_path(product)

    expect(page).not_to have_content("No Images Found.")
    within("table.index") do
      # ensure no duplicate images are displayed
      expect(page).to have_css("tbody tr", count: 1)

      # ensure variant header is not displayed
      within("thead") do
        expect(page).not_to have_content("Variant")
      end

      # ensure correct cell count
      expect(page).to have_css("thead th", count: 3)
    end
  end
end
