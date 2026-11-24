# frozen_string_literal: true

require "spec_helper"

RSpec.describe "SolidusAdmin::ProductImagesController", type: :request do
  let(:admin_user) { create(:admin_user) }
  let!(:product) { create(:product) }

  before do
    allow_any_instance_of(SolidusAdmin::BaseController)
      .to receive(:spree_current_user)
      .and_return(admin_user)
  end

  def upload_image(filename)
    Rack::Test::UploadedFile.new(
      File.open(File.join(
        Spree::Core::Engine.root, "lib/spree/testing_support/fixtures", filename
      )),
      "image/jpeg"
    )
  end

  describe "POST /create" do
    context "with valid parameters" do
      let(:valid_attributes) { {attachment: [upload_image("blank.jpg")]} }

      it "creates a new image on the product master" do
        expect {
          post solidus_admin.product_images_path(product),
            params: {image: valid_attributes}
        }.to change(Spree::Image, :count).by(1)

        image = Spree::Image.last
        expect(image.viewable).to eq(product.master)
      end

      it "redirects to the product show page" do
        post solidus_admin.product_images_path(product), params: {image: valid_attributes}
        expect(response).to redirect_to(solidus_admin.product_path(product))
        expect(response).to have_http_status(:see_other)
      end
    end

    context "without attachments" do
      it "does not create an image and renders unprocessable entity" do
        expect {
          post solidus_admin.product_images_path(product), params: {image: {attachment: [""]}}
        }.not_to change(Spree::Image, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with an invalid attachment" do
      let(:invalid_attributes) do
        {attachment: [Rack::Test::UploadedFile.new(
          File.join(Spree::Core::Engine.root, "lib/spree/testing_support/fixtures/file.txt"),
          "text/plain"
        )]}
      end

      it "does not create an image and renders the error" do
        expect {
          post solidus_admin.product_images_path(product), params: {image: invalid_attributes}
        }.not_to change(Spree::Image, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("file.txt: Attachment is not an image")
      end
    end
  end

  describe "DELETE /destroy" do
    let!(:image) { create(:image, viewable: product.master) }

    it "destroys the image" do
      expect {
        delete solidus_admin.product_image_path(product, image)
      }.to change(Spree::Image, :count).by(-1)
    end

    it "redirects to the product show page" do
      delete solidus_admin.product_image_path(product, image)
      expect(response).to redirect_to(solidus_admin.product_path(product))
      expect(response).to have_http_status(:see_other)
    end

    context "with batch delete (array of ids)" do
      let!(:image2) { create(:image, viewable: product.master) }

      it "destroys all selected images" do
        expect {
          delete solidus_admin.product_images_path(product), params: {id: [image.id, image2.id]}
        }.to change(Spree::Image, :count).by(-2)
      end

      it "redirects to the product show page" do
        delete solidus_admin.product_images_path(product), params: {id: [image.id, image2.id]}
        expect(response).to redirect_to(solidus_admin.product_path(product))
        expect(response).to have_http_status(:see_other)
      end
    end
  end
end
