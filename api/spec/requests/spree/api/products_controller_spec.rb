# frozen_string_literal: true

require 'spec_helper'
require 'shared_examples/protect_product_actions'

module Spree
  describe Spree::Api::ProductsController, type: :request do
    let!(:product) { create(:product) }
    let!(:inactive_product) { create(:product, available_on: Time.current.tomorrow, name: "inactive") }
    let(:base_attributes) { Api::ApiHelpers.product_attributes }
    let(:show_attributes) { base_attributes.dup.push(:has_variants) }
    let(:new_attributes) { base_attributes }

    let(:product_data) do
      { name: "The Other Product",
        price: 19.99,
        shipping_category_id: create(:shipping_category).id }
    end
    let(:attributes_for_variant) do
      attributes = attributes_for(:variant).except(:option_values, :product)
      attributes.merge({
        options: [
          { name: "size", value: "small" },
          { name: "color", value: "black" }
        ]
      })
    end

    before do
      stub_authentication!
    end

    context "as a normal user" do
      context "with caching enabled" do
        let!(:product_2) { create(:product) }

        before do
          ActionController::Base.perform_caching = true
        end

        it "returns unique products" do
          get spree.api_products_path
          product_ids = json_response["products"].map { |product| product["id"] }
          expect(product_ids.uniq.count).to eq(product_ids.count)
        end

        after do
          ActionController::Base.perform_caching = false
        end
      end

      it "retrieves a list of products" do
        get spree.api_products_path
        expect(json_response["products"].first).to have_attributes(show_attributes)
        expect(json_response["total_count"]).to eq(1)
        expect(json_response["current_page"]).to eq(1)
        expect(json_response["pages"]).to eq(1)
        expect(json_response["per_page"]).to eq(Kaminari.config.default_per_page)
      end

      it "retrieves a list of products by id" do
        get spree.api_products_path, params: { ids: [product.id] }
        expect(json_response["products"].first).to have_attributes(show_attributes)
        expect(json_response["total_count"]).to eq(1)
        expect(json_response["current_page"]).to eq(1)
        expect(json_response["pages"]).to eq(1)
        expect(json_response["per_page"]).to eq(Kaminari.config.default_per_page)
      end

      context "product has more than one price" do
        before { product.master.prices.create currency: "EUR", amount: 22 }

        it "returns distinct products only" do
          get spree.api_products_path
          expect(assigns(:products).map(&:id).uniq).to eq assigns(:products).map(&:id)
        end
      end

      it "retrieves a list of products by ids string" do
        second_product = create(:product)
        get spree.api_products_path, params: { ids: [product.id, second_product.id].join(",") }
        expect(json_response["products"].first).to have_attributes(show_attributes)
        expect(json_response["products"][1]).to have_attributes(show_attributes)
        expect(json_response["total_count"]).to eq(2)
        expect(json_response["current_page"]).to eq(1)
        expect(json_response["pages"]).to eq(1)
        expect(json_response["per_page"]).to eq(Kaminari.config.default_per_page)
      end

      it "does not return inactive products when queried by ids" do
        get spree.api_products_path, params: { ids: [inactive_product.id] }
        expect(json_response["count"]).to eq(0)
      end

      it "does not list unavailable products" do
        get spree.api_products_path
        expect(json_response["products"].first["name"]).not_to eq("inactive")
      end

      context "pagination" do
        it "can select the next page of products" do
          create(:product)
          get spree.api_products_path, params: { page: 2, per_page: 1 }
          expect(json_response["products"].first).to have_attributes(show_attributes)
          expect(json_response["total_count"]).to eq(2)
          expect(json_response["current_page"]).to eq(2)
          expect(json_response["pages"]).to eq(2)
        end

        it 'can control the page size through a parameter' do
          create(:product)
          get spree.api_products_path, params: { per_page: 1 }
          expect(json_response['count']).to eq(1)
          expect(json_response['total_count']).to eq(2)
          expect(json_response['current_page']).to eq(1)
          expect(json_response['pages']).to eq(2)
        end
      end

      it "can search for products" do
        create(:product, name: "The best product in the world")
        get spree.api_products_path, params: { q: { name_cont: "best" } }
        expect(json_response["products"].first).to have_attributes(show_attributes)
        expect(json_response["count"]).to eq(1)
      end

      it "gets a single product" do
        product.master.images.create!(attachment: image("thinking-cat.jpg"))
        product.variants.create!
        product.variants.first.images.create!(attachment: image("thinking-cat.jpg"))
        product.set_property("spree", "rocks")
        product.taxons << create(:taxon)

        get spree.api_product_path(product)

        expect(json_response).to have_attributes(show_attributes)
        expect(json_response['variants'].first).to have_attributes([:name,
                                                                    :is_master,
                                                                    :price,
                                                                    :images,
                                                                    :in_stock])

        expect(json_response['variants'].first['images'].first).to have_attributes([:attachment_file_name,
                                                                                    :attachment_width,
                                                                                    :attachment_height,
                                                                                    :attachment_content_type,
                                                                                    :mini_url,
                                                                                    :small_url,
                                                                                    :product_url,
                                                                                    :large_url])

        expect(json_response["product_properties"].first).to have_attributes([:value,
                                                                              :product_id,
                                                                              :property_name])

        expect(json_response["classifications"].first).to have_attributes([:taxon_id, :position, :taxon])
        expect(json_response["classifications"].first['taxon']).to have_attributes([:id, :name, :pretty_name, :permalink, :taxonomy_id, :parent_id])
      end

      context "tracking is disabled" do
        before { stub_spree_preferences(track_inventory_levels: false) }

        it "still displays valid json with total_on_hand Float::INFINITY" do
          get spree.api_product_path(product)
          expect(response).to be_ok
          expect(json_response[:total_on_hand]).to eq nil
        end
      end

      context "finds a product by slug first then by id" do
        let!(:other_product) { create(:product, slug: "these-are-not-the-droids-you-are-looking-for") }

        before do
          product.update_column(:slug, "#{other_product.id}-and-1-ways")
        end

        specify do
          get spree.api_product_path(product)
          expect(json_response["slug"]).to match(/and-1-ways/)
          product.discard

          get spree.api_product_path(other_product)
          expect(json_response["slug"]).to match(/droids/)
        end
      end

      it "cannot see inactive products" do
        get spree.api_product_path(inactive_product)
        assert_not_found!
      end

      it "returns a 404 error when it cannot find a product" do
        get spree.api_product_path("non-existant")
        assert_not_found!
      end

      it "can learn how to create a new product" do
        get spree.new_api_product_path
        expect(json_response["attributes"]).to eq(new_attributes.map(&:to_s))
        required_attributes = json_response["required_attributes"]
        expect(required_attributes).to include("name")
        expect(required_attributes).to include("price")
        expect(required_attributes).to include("shipping_category_id")
      end

      it_behaves_like "modifying product actions are restricted"
    end

    context "as an admin" do
      let(:taxon_1) { create(:taxon) }
      let(:taxon_2) { create(:taxon) }

      sign_in_as_admin!

      it "can see all products" do
        get spree.api_products_path
        expect(json_response["products"].count).to eq(2)
        expect(json_response["count"]).to eq(2)
        expect(json_response["current_page"]).to eq(1)
        expect(json_response["pages"]).to eq(1)
      end

      # Regression test for https://github.com/spree/spree/issues/1626
      context "deleted products" do
        before do
          create(:product, deleted_at: 1.day.ago)
        end

        it "does not include deleted products" do
          get spree.api_products_path
          expect(json_response["products"].count).to eq(2)
        end

        it "can include deleted products" do
          get spree.api_products_path, params: { show_deleted: 1 }
          expect(json_response["products"].count).to eq(3)
        end
      end

      describe "creating a product" do
        it "can create a new product" do
          post spree.api_products_path, params: {
                                          product: { name: "The Other Product",
                                                                          price: 19.99,
                                                                          shipping_category_id: create(:shipping_category).id }
          }
          expect(json_response).to have_attributes(base_attributes)
          expect(response.status).to eq(201)
        end

        it "creates with embedded variants" do
          product_data[:variants] = [attributes_for_variant, attributes_for_variant]

          post spree.api_products_path, params: { product: product_data }
          expect(response.status).to eq 201

          variants = json_response['variants']
          expect(variants.count).to eq(2)
          expect(variants.last['option_values'][0]['name']).to eq('small')
          expect(variants.last['option_values'][0]['option_type_name']).to eq('size')

          expect(json_response['option_types'].count).to eq(2) # size, color
        end

        it "can create a new product with embedded product_properties" do
          product_data[:product_properties_attributes] = [{
              property_name: "fabric",
              value: "cotton"
            }]

          post spree.api_products_path, params: { product: product_data }

          expect(json_response['product_properties'][0]['property_name']).to eq('fabric')
          expect(json_response['product_properties'][0]['value']).to eq('cotton')
        end

        it "can create a new product with option_types" do
          product_data[:option_types] = ['size', 'color']

          post spree.api_products_path, params: { product: product_data }
          expect(json_response['option_types'].count).to eq(2)
        end

        it "creates with shipping categories" do
          hash = { name: "The Other Product",
                   price: 19.99,
                   shipping_category: "Free Ships" }

          post spree.api_products_path, params: { product: hash }
          expect(response.status).to eq 201

          shipping_id = ShippingCategory.find_by(name: "Free Ships").id
          expect(json_response['shipping_category_id']).to eq shipping_id
        end

        context "when tracking is disabled" do
          before { stub_spree_preferences(track_inventory_levels: false) }

          it "still displays valid json with total_on_hand Float::INFINITY" do
            post spree.api_products_path, params: {
              product: {
                name: "The Other Product",
                price: 19.99,
                shipping_category_id: create(:shipping_category).id
              }
            }

            expect(response.status).to eq(201)
            expect(json_response['total_on_hand']).to eq nil
          end
        end

        it "puts the created product in the given taxon" do
          product_data[:taxon_ids] = taxon_1.id.to_s
          post spree.api_products_path, params: { product: product_data }
          expect(json_response["taxon_ids"]).to eq([taxon_1.id])
        end

        # Regression test for https://github.com/spree/spree/issues/4123
        it "puts the created product in the given taxons" do
          product_data[:taxon_ids] = [taxon_1.id, taxon_2.id].join(',')
          post spree.api_products_path, params: { product: product_data }
          expect(json_response["taxon_ids"]).to eq([taxon_1.id, taxon_2.id])
        end

        # Regression test for https://github.com/spree/spree/issues/2140
        context "with authentication_required set to false" do
          before do
            stub_spree_preferences(Spree::Api::Config, requires_authentication: false)
          end

          it "can still create a product" do
            post spree.api_products_path, params: { product: product_data, token: "fake" }
            expect(json_response).to have_attributes(show_attributes)
            expect(response.status).to eq(201)
          end
        end

        it "cannot create a new product with invalid attributes" do
          post spree.api_products_path, params: { product: { foo: :bar } }
          expect(response.status).to eq(422)
          expect(json_response["error"]).to eq("Invalid resource. Please fix errors and try again.")
          errors = json_response["errors"]
          expect(errors.keys).to include("name", "price", "shipping_category_id")
        end
      end

      context 'updating a product' do
        it "can update a product" do
          put spree.api_product_path(product), params: { product: { name: "New and Improved Product!" } }
          expect(response.status).to eq(200)
        end

        it "can create new option types on a product" do
          put spree.api_product_path(product), params: { product: { option_types: ['shape', 'color'] } }
          expect(json_response['option_types'].count).to eq(2)
        end

        it "can create new variants on a product" do
          put spree.api_product_path(product), params: { product: { variants: [attributes_for_variant, attributes_for_variant.merge(sku: "ABC-#{Kernel.rand(9999)}")] } }
          expect(response.status).to eq 200
          expect(json_response['variants'].count).to eq(2) # 2 variants

          variants = json_response['variants'].reject { |variant| variant['is_master'] }
          size_option_value = variants.last['option_values'].detect{ |value| value['option_type_name'] == 'size' }
          expect(size_option_value['name']).to eq('small')

          expect(json_response['option_types'].count).to eq(2) # size, color
        end

        it "can update an existing variant on a product" do
          variant_hash = {
            sku: '123', price: 19.99, options: [{ name: "size", value: "small" }]
          }
          variant_id = product.variants.create!({ product: product }.merge(variant_hash)).id

          put spree.api_product_path(product), params: { product: {
            variants: [
              variant_hash.merge(
                id: variant_id.to_s,
                sku: '456',
                options: [{ name: "size", value: "large" }]
              )
            ]
          } }

          expect(json_response['variants'].count).to eq(1)
          variants = json_response['variants'].reject { |variant| variant['is_master'] }
          expect(variants.last['option_values'][0]['name']).to eq('large')
          expect(variants.last['sku']).to eq('456')
          expect(variants.count).to eq(1)
        end

        it "cannot update a product with an invalid attribute" do
          put spree.api_product_path(product), params: { product: { name: "" } }
          expect(response.status).to eq(422)
          expect(json_response["error"]).to eq("Invalid resource. Please fix errors and try again.")
          expect(json_response["errors"]["name"]).to eq(["can't be blank"])
        end

        # Regression test for https://github.com/spree/spree/issues/4123
        it "puts the created product in the given taxon" do
          put spree.api_product_path(product), params: { product: { taxon_ids: taxon_1.id.to_s } }
          expect(json_response["taxon_ids"]).to eq([taxon_1.id])
        end

        # Regression test for https://github.com/spree/spree/issues/4123
        it "puts the created product in the given taxons" do
          put spree.api_product_path(product), params: { product: { taxon_ids: [taxon_1.id, taxon_2.id].join(',') } }
          expect(json_response["taxon_ids"]).to match_array([taxon_1.id, taxon_2.id])
        end
      end

      it "can delete a product" do
        expect(product.deleted_at).to be_nil
        delete spree.api_product_path(product)
        expect(response.status).to eq(204)
        expect(product.reload.deleted_at).not_to be_nil
      end
    end
  end
end
