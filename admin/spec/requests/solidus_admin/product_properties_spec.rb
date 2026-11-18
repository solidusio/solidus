# frozen_string_literal: true

require "spec_helper"

RSpec.describe "SolidusAdmin::ProductPropertiesController", type: :request do
  let(:admin_user) { create(:admin_user) }
  let(:product) { create(:product) }

  before do
    allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)
  end

  describe "GET /new" do
    let!(:brand_property) { create(:product_property, product:, property: create(:property, name: "brand"), position: 3) }

    it "appends a blank row to the specifications dialog" do
      get solidus_admin.new_product_product_properties_path(product, format: :turbo_stream)

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/vnd.turbo-stream.html")
      expect(response.body).to include('action="append" target="specification_rows"')
      expect(response.body).to match(/name="product\[product_properties_attributes\]\[\d+\]\[property_name\]"/)
      expect(response.body).to match(/name="product\[product_properties_attributes\]\[\d+\]\[value\]"/)
      expect(response.body).to match(/name="product\[product_properties_attributes\]\[\d+\]\[_destroy\]"/)
    end

    it "places the row after the last persisted one" do
      get solidus_admin.new_product_product_properties_path(product, format: :turbo_stream)

      expect(response.body).to match(/name="product\[product_properties_attributes\]\[\d+\]\[position\]" value="4"/)
    end
  end

  describe "GET /edit" do
    it "renders the specifications dialog" do
      get solidus_admin.edit_product_product_properties_path(product)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Edit specifications")
    end

    context "when the user cannot manage products" do
      let(:admin_user) { create(:limited_admin_user, permissions: [Spree::PermissionSets::ProductDisplay]) }

      it "responds as forbidden" do
        get solidus_admin.edit_product_product_properties_path(product)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "PATCH /update" do
    let(:brand) { create(:property, name: "brand", presentation: "Brand") }
    let!(:brand_property) { create(:product_property, product:, property: brand, value: "Solidus") }
    let(:params) do
      {
        product: {
          product_properties_attributes: {
            "0" => {id: brand_property.id, property_name: "brand", value: "Solidus", _destroy: "1"},
            "1" => {property_name: "care", value: "Dry clean only"}
          }
        }
      }
    end

    it "updates the product properties and responds with a turbo stream" do
      patch solidus_admin.product_product_properties_path(product, format: :turbo_stream), params: params

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/vnd.turbo-stream.html")
      expect(response.body).to include('target="specifications_panel"')
      expect(product.product_properties.map { |product_property| [product_property.property_name, product_property.value] })
        .to eq([["care", "Dry clean only"]])
    end

    it "redirects to the product when not requested as a turbo stream" do
      patch solidus_admin.product_product_properties_path(product), params: params

      expect(response).to redirect_to(solidus_admin.product_path(product))
      expect(response).to have_http_status(:see_other)
    end

    context "with explicit positions" do
      let(:properties) do
        others = %w[gender care origin].map do |name|
          create(:product_property, product:, property: create(:property, name:), value: name)
        end

        [brand_property, *others]
      end
      let(:params) do
        {
          product: {
            product_properties_attributes: {
              "0" => {id: properties[0].id, property_name: "brand", position: 3},
              "1" => {id: properties[1].id, property_name: "gender", position: 2},
              "2" => {id: properties[2].id, property_name: "care", position: 4},
              "3" => {id: properties[3].id, property_name: "origin", position: 1}
            }
          }
        }
      end

      it "persists the positions as sent" do
        patch solidus_admin.product_product_properties_path(product, format: :turbo_stream), params: params

        expect(response).to have_http_status(:ok)
        expect(product.product_properties.reload.map { |product_property| [product_property.property_name, product_property.position] })
          .to eq([["origin", 1], ["gender", 2], ["brand", 3], ["care", 4]])
      end
    end

    context "when the product cannot be saved" do
      before do
        allow_any_instance_of(Spree::Product).to receive(:save).and_return(false)
      end

      it "re-renders the dialog with a 422 status" do
        patch solidus_admin.product_product_properties_path(product, format: :turbo_stream), params: params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Edit specifications")
      end

      it "keeps the removed rows marked for destruction in the re-rendered dialog" do
        patch solidus_admin.product_product_properties_path(product), params: params

        expect(response).to have_http_status(:unprocessable_entity)
        dialog = Capybara.string(response.body)
        expect(dialog).to have_field("Value", with: "Solidus")
        expect(dialog).to have_field("Value", with: "Dry clean only")
        expect(dialog.all(:checkbox, "Remove").map(&:checked?)).to eq([true, false])
      end
    end
  end
end
