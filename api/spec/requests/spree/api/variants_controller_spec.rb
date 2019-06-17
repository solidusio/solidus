# frozen_string_literal: true

require 'spec_helper'

module Spree
  describe Api::VariantsController, type: :request do
    let!(:product) { create(:product) }
    let!(:variant) do
      variant = product.master
      variant.option_values << create(:option_value)
      variant
    end

    let!(:base_attributes) { Api::ApiHelpers.variant_attributes }
    let!(:show_attributes) { base_attributes.dup.push(:in_stock, :display_price, :variant_properties) }
    let!(:new_attributes) { base_attributes }

    before do
      stub_authentication!
    end

    describe "#index" do
      it "can see a paginated list of variants" do
        get spree.api_variants_path
        first_variant = json_response["variants"].first
        expect(first_variant).to have_attributes(show_attributes)
        expect(first_variant["stock_items"]).to be_present
        expect(json_response["count"]).to eq(1)
        expect(json_response["current_page"]).to eq(1)
        expect(json_response["pages"]).to eq(1)
      end

      it 'can control the page size through a parameter' do
        create(:variant)
        get spree.api_variants_path, params: { per_page: 1 }
        expect(json_response['count']).to eq(1)
        expect(json_response['current_page']).to eq(1)
        expect(json_response['pages']).to eq(3)
      end

      it 'can query the results through a paramter' do
        expected_result = create(:variant, sku: 'FOOBAR')
        get spree.api_variants_path, params: { q: { sku_cont: 'FOO' } }
        expect(json_response['count']).to eq(1)
        expect(json_response['variants'].first['sku']).to eq expected_result.sku
      end

      it "variants returned contain option values data" do
        get spree.api_variants_path
        option_values = json_response["variants"].last["option_values"]
        expect(option_values.first).to have_attributes([:name,
                                                        :presentation,
                                                        :option_type_name,
                                                        :option_type_id])
      end

      it "variants returned contain images data" do
        variant.images.create!(attachment: image("thinking-cat.jpg"))

        get spree.api_variants_path

        expect(json_response["variants"].last).to have_attributes([:images])
        expect(json_response['variants'].first['images'].first).to have_attributes([:attachment_file_name,
                                                                                    :attachment_width,
                                                                                    :attachment_height,
                                                                                    :attachment_content_type,
                                                                                    :mini_url,
                                                                                    :small_url,
                                                                                    :product_url,
                                                                                    :large_url])
      end

      # Regression test for https://github.com/spree/spree/issues/2141
      context "a deleted variant" do
        before do
          variant.update_column(:deleted_at, Time.current)
        end

        it "is not returned in the results" do
          get spree.api_variants_path
          expect(json_response["variants"].count).to eq(0)
        end

        it "is not returned even when show_deleted is passed" do
          get spree.api_variants_path, params: { show_deleted: true }
          expect(json_response["variants"].count).to eq(0)
        end
      end

      context "stock filtering" do
        context "only variants in stock" do
          subject { get spree.api_variants_path, params: { in_stock_only: "true" } }

          context "variant is out of stock" do
            before do
              variant.stock_items.update_all(count_on_hand: 0)
            end

            it "is not returned in the results" do
              subject
              expect(json_response["variants"].count).to eq 0
            end
          end

          context "variant is in stock" do
            before do
              variant.stock_items.update_all(count_on_hand: 10)
            end

            it "is returned in the results" do
              subject
              expect(json_response["variants"].count).to eq 1
            end
          end
        end

        context "only suplliable variants" do
          subject { get spree.api_variants_path, params: { suppliable_only: "true" } }

          context "variant is backorderable" do
            before do
              variant.stock_items.update_all(count_on_hand: 0, backorderable: true)
            end

            it "is not returned in the results" do
              subject
              expect(json_response["variants"].count).to eq 1
            end
          end

          context "variant is unsuppliable" do
            before do
              variant.stock_items.update_all(count_on_hand: 0, backorderable: false)
            end

            it "is returned in the results" do
              subject
              expect(json_response["variants"].count).to eq 0
            end
          end
        end

        context "all variants" do
          subject { get spree.api_variants_path, params: { in_stock_only: "false" } }

          context "variant is out of stock" do
            before do
              variant.stock_items.update_all(count_on_hand: 0)
            end

            it "is returned in the results" do
              subject
              expect(json_response["variants"].count).to eq 1
            end
          end

          context "variant is in stock" do
            before do
              variant.stock_items.update_all(count_on_hand: 10)
            end

            it "is returned in the results" do
              subject
              expect(json_response["variants"].count).to eq 1
            end
          end
        end
      end

      context "pagination" do
        it "can select the next page of variants" do
          create(:variant)
          get spree.api_variants_path, params: { page: 2, per_page: 1 }
          expect(json_response["variants"].first).to have_attributes(show_attributes)
          expect(json_response["total_count"]).to eq(3)
          expect(json_response["current_page"]).to eq(2)
          expect(json_response["pages"]).to eq(3)
        end
      end

      context "stock item filter" do
        let(:stock_location) { variant.stock_locations.first }
        let!(:inactive_stock_location) { create(:stock_location, propagate_all_variants: true, name: "My special stock location", active: false) }

        it "only returns stock items for active stock locations" do
          get spree.api_variants_path
          variant = json_response['variants'].first
          stock_items = variant['stock_items'].map { |si| si['stock_location_name'] }

          expect(stock_items).to include stock_location.name
          expect(stock_items).not_to include inactive_stock_location.name
        end
      end
    end

    describe "#show" do
      subject do
        get spree.api_variant_path(variant)
      end

      it "can see a single variant" do
        subject
        expect(json_response).to have_attributes(show_attributes)
        expect(json_response["stock_items"]).to be_present
        option_values = json_response["option_values"]
        expect(option_values.first).to have_attributes([:name,
                                                        :presentation,
                                                        :option_type_name,
                                                        :option_type_id])
      end

      it "can see a single variant with images" do
        variant.images.create!(attachment: image("thinking-cat.jpg"))

        subject

        expect(json_response).to have_attributes(show_attributes + [:images])
        option_values = json_response["option_values"]
        expect(option_values.first).to have_attributes([:name,
                                                        :presentation,
                                                        :option_type_name,
                                                        :option_type_id])
      end

      context "variant doesn't have variant properties" do
        before { subject }

        it "contains the expected attributes" do
          expect(json_response).to have_attributes(show_attributes)
        end

        it "variant properties is an empty list" do
          expect(json_response["variant_properties"]).to eq []
        end
      end

      context "variant has variant properties" do
        let!(:rule) { create(:variant_property_rule, product: variant.product, option_value: variant.option_values.first) }

        before { subject }

        it "contains the expected attributes" do
          expect(json_response).to have_attributes(show_attributes)
        end

        it "variant properties is an array of variant property values" do
          expected_attrs = [:id, :property_id, :value, :property_name]
          expect(json_response["variant_properties"].first).to have_attributes(expected_attrs)
        end
      end

      context "when tracking is disabled" do
        before do
          stub_spree_preferences(track_inventory_levels: false)
          subject
        end

        it "still displays valid json with total_on_hand Float::INFINITY" do
          expect(response.status).to eq(200)
          expect(json_response['total_on_hand']).to eq nil
        end
      end
    end

    it "can learn how to create a new variant" do
      get spree.new_api_variant_path(variant)
      expect(json_response["attributes"]).to eq(new_attributes.map(&:to_s))
      expect(json_response["required_attributes"]).to be_empty
    end

    it "cannot create a new variant if not an admin" do
      post spree.api_variants_path, params: { variant: { sku: "12345" } }
      assert_unauthorized!
    end

    it "cannot update a variant" do
      put spree.api_variant_path(variant), params: { variant: { sku: "12345" } }
      assert_not_found!
    end

    it "cannot delete a variant" do
      delete spree.api_variant_path(variant)
      assert_not_found!
      expect { variant.reload }.not_to raise_error
    end

    context "as an admin" do
      sign_in_as_admin!

      # Test for https://github.com/spree/spree/issues/2141
      context "deleted variants" do
        before do
          variant.update_column(:deleted_at, Time.current)
        end

        it "are visible by admin" do
          get spree.api_variants_path, params: { show_deleted: 1 }
          expect(json_response["variants"].count).to eq(1)
        end
      end

      it "can create a new variant" do
        post spree.api_product_variants_path(product), params: { variant: { sku: "12345" } }
        expect(json_response).to have_attributes(new_attributes)
        expect(response.status).to eq(201)
        expect(json_response["sku"]).to eq("12345")

        expect(variant.product.variants.count).to eq(1)
      end

      it "creates new variants with nested option values" do
        option_values = create_list(:option_value, 2)
        expect do
          post spree.api_product_variants_path(product), params: {
            variant: {
              sku: "12345",
              option_value_ids: option_values.map(&:id)
            }
          }
        end.to change { Spree::OptionValuesVariant.count }.by(2)
      end

      it "can update a variant" do
        put spree.api_variant_path(variant), params: { variant: { sku: "12345" } }
        expect(response.status).to eq(200)
      end

      it "can delete a variant" do
        delete spree.api_variant_path(variant)
        expect(response.status).to eq(204)
        expect { Spree::Variant.find(variant.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'variants returned contain cost price data' do
        get spree.api_variants_path
        expect(json_response["variants"].first.key?(:cost_price)).to eq true
      end
    end
  end
end
