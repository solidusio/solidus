# frozen_string_literal: true

require 'spec_helper'

module Spree
  describe Spree::Api::ImagesController, type: :request do
    let!(:product) { create(:product) }
    let!(:attributes) {
      [:id, :position, :attachment_content_type,
       :attachment_file_name, :type, :attachment_updated_at, :attachment_width,
       :attachment_height, :alt]
    }

    before do
      stub_authentication!
    end

    context "as an admin" do
      sign_in_as_admin!

      it "can upload a new image for a variant" do
        expect do
          post spree.api_product_images_path(product.id), params: {
            image: {
              attachment: upload_image('thinking-cat.jpg'),
              viewable_type: 'Spree::Variant',
              viewable_id: product.master.to_param
            },
          }
          expect(response.status).to eq(201)
          expect(json_response).to have_attributes(attributes)
        end.to change(Image, :count).by(1)
      end

      context "working with an existing image" do
        let!(:product_image) { product.master.images.create!(attachment: image('thinking-cat.jpg')) }

        it "can get a single product image" do
          get spree.api_product_image_path(product.id, product_image)
          expect(response.status).to eq(200)
          expect(json_response).to have_attributes(attributes)
        end

        it "can get a single variant image" do
          get spree.api_variant_image_path(product.master.id, product_image)
          expect(response.status).to eq(200)
          expect(json_response).to have_attributes(attributes)
        end

        it "can get a list of product images" do
          get spree.api_product_images_path(product.id)
          expect(response.status).to eq(200)
          expect(json_response).to have_key("images")
          expect(json_response["images"].first).to have_attributes(attributes)
        end

        it "can get a list of variant images" do
          get spree.api_variant_images_path(product.master.id)
          expect(response.status).to eq(200)
          expect(json_response).to have_key("images")
          expect(json_response["images"].first).to have_attributes(attributes)
        end

        it "can update image data" do
          expect(product_image.position).to eq(1)
          put spree.api_variant_image_path(product.id, product_image), params: { image: { position: 2 } }
          expect(response.status).to eq(200)
          expect(json_response).to have_attributes(attributes)
          expect(product_image.reload.position).to eq(2)
        end

        it "can delete an image" do
          delete spree.api_variant_image_path(product.id, product_image)
          expect(response.status).to eq(204)
          expect { product_image.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context "as a non-admin" do
      let(:product_image) { product.master.images.create!(attachment: image('thinking-cat.jpg')) }

      it "cannot create an image" do
        post spree.api_product_images_path(product.id)
        assert_unauthorized!
      end

      it "cannot update an image" do
        put spree.api_product_image_path(product.id, product_image)
        assert_not_found!
      end

      it "cannot delete an image" do
        delete spree.api_product_image_path(product.id, product_image)
        assert_not_found!
      end
    end
  end
end
