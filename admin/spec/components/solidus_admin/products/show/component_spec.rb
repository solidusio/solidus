# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::Products::Show::Component, type: :component do
  let(:product) { create(:product) }
  let(:component) { described_class.new(product: product) }

  describe "media section" do
    it "lists all product images" do
      image1 = create(:image, viewable: product.master, attachment: File.open(Spree::Core::Engine.root.join("lib", "spree", "testing_support", "fixtures", "blank.jpg")))
      image2 = create(:image, viewable: product.master, attachment: File.open(Spree::Core::Engine.root.join("lib", "spree", "testing_support", "fixtures", "blank.jpg")))

      ActiveStorage::Current.url_options = {host: "example.com"}
      render_inline(component)

      expect(page).to have_content(image1.filename)
      expect(page).to have_content(image2.filename)
    end

    it "shows no images message when product has no images" do
      ActiveStorage::Current.url_options = {host: "example.com"}
      render_inline(component)

      expect(page).to have_content(/No images found/i)
    end
  end
end
