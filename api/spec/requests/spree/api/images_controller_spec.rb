# frozen_string_literal: true

require 'spec_helper'
require "private_address_check/tcpsocket_ext"

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

      it 'can upload a new image from a valid URL' do
        VCR.use_cassette('api-image-upload') do
          expect do
            post spree.api_product_images_path(product.id), params: {
              image: {
                attachment: 'https://raw.githubusercontent.com/solidusio/brand/1827e7afb7ebcf5a1fc9cf7bf6cf9d277183ef11/PNG/solidus-logo-dark.png',
                viewable_type: 'Spree::Variant',
                viewable_id: product.master.to_param,
                alt: 'just a test'
              },
            }
            expect(response.status).to eq(201)
            expect(json_response).to have_attributes(attributes)
            expect(json_response[:alt]).to eq('just a test')
          end.to change(Image, :count).by(1)
        end
      end

      it 'will raise an exception if URL passed as attachment parameter attempts to redirect' do
        VCR.use_cassette('api-image-upload-redirect') do
          expect do
            post spree.api_product_images_path(product.id), params: {
              image: {
                attachment: 'https://github.com/solidusio/brand/raw/1827e7afb7ebcf5a1fc9cf7bf6cf9d277183ef11/PNG/solidus-logo-dark.png',
                viewable_type: 'Spree::Variant',
                viewable_id: product.master.to_param,
              },
            }
          end.to raise_error(OpenURI::HTTPRedirect)
        end
      end

      it 'will raise an exception if URL passed is a private address' do
        expect do
          post spree.api_product_images_path(product.id), params: {
            image: {
              attachment: 'https://10.10.10.2/foo.png',
              viewable_type: 'Spree::Variant',
              viewable_id: product.master.to_param,
            },
          }
        end.to raise_error(PrivateAddressCheck::PrivateConnectionAttemptedError)
      end

      context "working with an existing product image" do
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
          put spree.api_variant_image_path(product.master.id, product_image), params: { image: { position: 2 } }
          expect(response.status).to eq(200)
          expect(json_response).to have_attributes(attributes)
          expect(product_image.reload.position).to eq(2)
        end

        it "can update image URL" do
          VCR.use_cassette('api-image-upload') do
            expect(product_image.position).to eq(1)
            put spree.api_variant_image_path(product.master.id, product_image), params: {
              image: {
                position: 2,
                attachment: 'https://raw.githubusercontent.com/solidusio/brand/1827e7afb7ebcf5a1fc9cf7bf6cf9d277183ef11/PNG/solidus-logo-dark.png'
              },
            }
            expect(response.status).to eq(200)
            expect(json_response).to have_attributes(attributes)
            expect(product_image.reload.position).to eq(2)
            expect(product_image.reload.attachment_height).to eq(420)
          end
        end

        it "can delete an image" do
          delete spree.api_variant_image_path(product.master.id, product_image)
          expect(response.status).to eq(204)
          expect { product_image.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'when image belongs to another product' do
        let!(:product_image) { another_product.master.images.create!(attachment: image('thinking-cat.jpg')) }
        let(:another_product) { create(:product) }

        it "cannot get an image of another product" do
          get spree.api_product_image_path(product.id, product_image)
          expect(response.status).to eq(404)
          expect(json_response['error']).to eq(I18n.t(:resource_not_found, scope: "spree.api"))
        end

        it "cannot get an image of another variant" do
          get spree.api_variant_image_path(product.master.id, product_image)
          expect(response.status).to eq(404)
          expect(json_response['error']).to eq(I18n.t(:resource_not_found, scope: "spree.api"))
        end

        it "cannot update image of another product" do
          expect(product_image.position).to eq(1)
          put spree.api_variant_image_path(product.master.id, product_image), params: { image: { position: 2 } }
          expect(response.status).to eq(404)
          expect(json_response['error']).to eq(I18n.t(:resource_not_found, scope: "spree.api"))
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
