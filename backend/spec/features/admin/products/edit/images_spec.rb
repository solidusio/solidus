require 'spec_helper'

describe "Product Images", :type => :feature do
  stub_authorization!

  let(:file_path) { Rails.root + "../../spec/support/ror_ringer.jpeg" }

  before do
    # Ensure attachment style keys are symbolized before running all tests
    # Otherwise this would result in this error:
    # undefined method `processors' for \"48x48>\
    Solidus::Image.attachment_definitions[:attachment][:styles].symbolize_keys!
  end

  context "uploading, editing, and deleting an image", :js => true do
    it "should allow an admin to upload and edit an image for a product" do
      Solidus::Image.attachment_definitions[:attachment].delete :storage

      create(:product)

      visit solidus.admin_path
      click_nav "Products"
      click_icon(:edit)
      click_link "Images"
      click_link "new_image_link"
      attach_file('image_attachment', file_path)
      click_button "Update"
      expect(page).to have_content("successfully created!")

      within_row(1) do
        click_icon(:edit)
      end
      fill_in "image_alt", :with => "ruby on rails t-shirt"
      click_button "Update"
      expect(page).to have_content("successfully updated!")
      expect(page).to have_content("ruby on rails t-shirt")

      accept_alert do
        click_icon :trash
      end
      expect(page).not_to have_content("ruby on rails t-shirt")
    end
  end

  # Regression test for #2228
  it "should see variant images" do
    variant = create(:variant)
    variant.images.create!(:attachment => File.open(file_path))
    visit solidus.admin_product_images_path(variant.product)

    expect(page).not_to have_content("No Images Found.")
    within("table.index") do
      expect(page).to have_content(variant.options_text)

      #ensure no duplicate images are displayed
      expect(page).to have_css("tbody tr", :count => 1)

      #ensure variant header is displayed
      within("thead") do
        expect(page).to have_content("Variant")
      end

      #ensure variant header is displayed
      within("tbody") do
        expect(page).to have_content("Size: S")
      end
    end
  end

  it "should not see variant column when product has no variants" do
    product = create(:product)
    product.images.create!(:attachment => File.open(file_path))
    visit solidus.admin_product_images_path(product)

    expect(page).not_to have_content("No Images Found.")
    within("table.index") do
      #ensure no duplicate images are displayed
      expect(page).to have_css("tbody tr", :count => 1)

      #ensure variant header is not displayed
      within("thead") do
        expect(page).not_to have_content("Variant")
      end

      #ensure correct cell count
      expect(page).to have_css("thead th", :count => 3)
    end
  end
end
