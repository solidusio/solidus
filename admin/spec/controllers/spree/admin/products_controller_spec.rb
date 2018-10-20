# frozen_string_literal: true

require 'spec_helper'

describe Spree::Admin::ProductsController, type: :controller do
  stub_authorization!

  context "#index" do
    let(:ability_user) { stub_model(Spree::LegacyUser, has_spree_role?: true) }

    # Regression test for https://github.com/spree/spree/issues/1259
    it "can find a product by SKU" do
      product = create(:product, sku: "ABC123")
      get :index, params: { q: { sku_start: "ABC123" } }
      expect(assigns[:collection]).not_to be_empty
      expect(assigns[:collection]).to include(product)
    end

    # Regression test for https://github.com/spree/spree/issues/1903
    context 'when soft deleted products exist' do
      let!(:soft_deleted_product) { create(:product, sku: "ABC123") }
      before { soft_deleted_product.discard }

      context 'when params[:q][:with_deleted] is not set' do
        let(:params) { { q: {} } }

        it 'filters out soft-deleted products by default' do
          get :index, params: params
          expect(assigns[:collection]).to_not include(soft_deleted_product)
        end
      end

      context 'when params[:q][:with_deleted] is set to "true"' do
        let(:params) { { q: { with_deleted: 'true' } } }

        it 'includes soft-deleted products' do
          get :index, params: params
          expect(assigns[:collection]).to include(soft_deleted_product)
        end
      end
    end
  end

  # regression test for https://github.com/spree/spree/issues/1370
  context "adding properties to a product" do
    let!(:product) { create(:product) }
    specify do
      put :update, params: { id: product.to_param, product: { product_properties_attributes: { "1" => { property_name: "Foo", value: "bar" } } } }
      expect(flash[:success]).to eq("Product #{product.name.inspect} has been successfully updated!")
    end
  end

  # regression test for https://github.com/solidusio/solidus/issues/2791
  context "creating a product" do
    before(:all) do
      create(:shipping_category)
    end

    it "creates a product" do
      post :create, params: {
             product: {
               name: "Product #1 - 9632",
               description: "As seen on TV!",
               price: 19.99,
               shipping_category_id: Spree::ShippingCategory.first.id,
             }
           }
      expect(flash[:success]).to eq("Product \"Product #1 - 9632\" has been successfully created!")
    end

    context "when there is a taxon" do
      let(:first_taxon) { create(:taxon) }

      it "creates a product with a taxon" do
        post :create, params: {
               product: {
                 name: "Product #1 - 9632",
                 description: "As seen on TV!",
                 price: 19.99,
                 shipping_category_id: Spree::ShippingCategory.first.id,
                 taxon_ids: first_taxon.id.to_s
               }
             }
        expect(flash[:success]).to eq("Product \"Product #1 - 9632\" has been successfully created!")
      end

      context "when their are multiple taxons" do
        let(:second_taxon) { create(:taxon) }

        it "creates a product with multiple taxons" do
          post :create, params: {
                 product: {
                   name: "Product #1 - 9632",
                   description: "As seen on TV!",
                   price: 19.99,
                   shipping_category_id: Spree::ShippingCategory.first.id,
                   taxon_ids: "#{first_taxon.id}, #{second_taxon.id}"
                 }
               }
          expect(flash[:success]).to eq("Product \"Product #1 - 9632\" has been successfully created!")
        end
      end
    end
  end

  context "adding taxons to a product" do
    let(:product) { create(:product) }
    let(:first_taxon) { create(:taxon) }

    it "adds a single taxon to a product" do
      put :update, params: { id: product.to_param, product: { taxon_ids: first_taxon.id.to_s } }
      expect(flash[:success]).to eq("Product #{product.name.inspect} has been successfully updated!")
    end

    context "when there are mulitple taxons" do
      let(:second_taxon) { create(:taxon) }

      it "adds multiple taxons to a product" do
        put :update, params: { id: product.to_param, product: { taxon_ids: "#{first_taxon.id}, #{second_taxon.id}" } }
        expect(flash[:success]).to eq("Product #{product.name.inspect} has been successfully updated!")
      end
    end
  end

  describe "creating variant property rules" do
    let(:first_property) { create(:property) }
    let(:second_property) { create(:property) }
    let(:option_value) { create(:option_value) }
    let!(:product) { create(:product, option_types: [option_value.option_type]) }
    let(:payload) do
      {
        id: product.to_param,
        product: {
          id: product.id,
          variant_property_rules_attributes: {
            "0" => {
              option_value_ids: option_value.id,
              values_attributes: {
                "0" => {
                  property_name: first_property.name,
                  value: "First"
                },
                "1" => {
                  property_name: second_property.name,
                  value: "Second"
                }
              }
            }
          }
        }
      }
    end

    subject { put :update, params: payload }

    it "creates a variant property rule" do
      expect { subject }.to change { product.variant_property_rules.count }.by(1)
    end

    it "creates a variant property rule condition" do
      expect { subject }.to change { product.variant_property_rule_conditions.count }.by(1)
    end

    it "creates a variant property rule value for the 'First' value" do
      subject
      expect(product.variant_property_rule_values.find_by(value: 'First')).to_not be_nil
    end

    it "creates a variant property rule value for the 'Second' value" do
      subject
      expect(product.variant_property_rule_values.find_by(value: 'Second')).to_not be_nil
    end

    it "redirects to the product properties page" do
      subject
      expect(response).to redirect_to(spree.admin_product_product_properties_path(product, ovi: [option_value.id]))
    end
  end

  describe "updating variant property rules" do
    let(:first_property) { create(:property) }
    let(:second_property) { create(:property) }
    let(:option_value) { create(:option_value) }
    let(:original_option_value) { create(:option_value) }
    let!(:product) { create(:product, option_types: [option_value.option_type]) }
    let!(:rule) do
      create(:variant_property_rule, product: product, option_value: original_option_value)
    end
    let(:payload) do
      {
        id: product.to_param,
        product: {
          id: product.id,
          variant_property_rules_attributes: {
            "0" => {
              id: rule.id,
              option_value_ids: option_value.id,
              values_attributes: {
                "0" => {
                  property_name: first_property.name,
                  value: "First Edit"
                },
                "1" => {
                  property_name: second_property.name,
                  value: "Second Edit"
                }
              }
            }
          }
        }
      }
    end

    subject { put :update, params: payload }

    it "does not create any new rules" do
      expect { subject }.to_not change { Spree::VariantPropertyRule.count }
    end

    it "replaces the rule's condition" do
      expect { subject }.to change { rule.reload.option_value_ids }.from([original_option_value.id]).to([option_value.id])
    end

    it "adds two values to the rule" do
      expect { subject }.to change { rule.values.count }.by(2)
    end

    it "creates the 'First Edit' value" do
      subject
      expect(rule.values.find_by(value: 'First Edit')).to_not be_nil
    end

    it "creates the 'Second Edit' value" do
      subject
      expect(rule.values.find_by(value: 'Second Edit')).to_not be_nil
    end

    it "redirects to the product properties page" do
      subject
      expect(response).to redirect_to(spree.admin_product_product_properties_path(product, ovi: [option_value.id]))
    end
  end

  context "cloning a product" do
    let!(:product) { create(:product) }

    it "duplicates the product" do
      expect do
        post :clone, params: { id: product.id }
      end.to change { Spree::Product.count }.by(1)
    end
  end

  # regression test for https://github.com/spree/spree/issues/801
  context "destroying a product" do
    let(:product) do
      product = create(:product)
      create(:variant, product: product)
      product
    end

    it "deletes all the variants (including master) for the product" do
      delete :destroy, params: { id: product }
      expect(product.reload.deleted_at).not_to be_nil
      product.variants_including_master.each do |variant|
        expect(variant.reload.deleted_at).not_to be_nil
      end
    end
  end
end
