require 'spec_helper'

describe Spree::Admin::ProductsController, :type => :controller do
  stub_authorization!

  context "#index" do
    let(:ability_user) { stub_model(Spree::LegacyUser, :has_spree_role? => true) }

    # Regression test for #1259
    it "can find a product by SKU" do
      product = create(:product, :sku => "ABC123")
      spree_get :index, :q => { :sku_start => "ABC123" }
      expect(assigns[:collection]).not_to be_empty
      expect(assigns[:collection]).to include(product)
    end
  end

  # regression test for #1370
  context "adding properties to a product" do
    let!(:product) { create(:product) }
    specify do
      spree_put :update, :id => product.to_param, :product => { :product_properties_attributes => { "1" => { :property_name => "Foo", :value => "bar" } } }
      expect(flash[:success]).to eq("Product #{product.name.inspect} has been successfully updated!")
    end

  end


  # regression test for #801
  context "destroying a product" do
    let(:product) do
      product = create(:product)
      create(:variant, :product => product)
      product
    end

    it "deletes all the variants (including master) for the product" do
      spree_delete :destroy, :id => product
      expect(product.reload.deleted_at).not_to be_nil
      product.variants_including_master.each do |variant|
        expect(variant.reload.deleted_at).not_to be_nil
      end
    end
  end

  context "stock" do
    let!(:product) { create(:product) }
    let!(:variant_1) { create(:variant, product: product) }
    let!(:variant_2) { create(:variant, product: product, option_values: variant_1.option_values) }
    let!(:variant_3) { create(:variant, product: product) }

    let(:sku) { variant_1.sku }
    let(:option_value_ids) { ["", variant_2.option_values.first.id] }
    subject { spree_get :stock, { sku: sku, option_value_ids: option_value_ids, hide_out_of_stock: "1", id: product.slug } }

    it "restricts stock location based on accessible attributes" do
      expect(Spree::StockLocation).to receive(:accessible_by).and_return([])
      spree_get :stock, :id => product
    end

    context "with a given sku" do
      it "finds the correct variants" do
        subject
        expect(assigns(:variants)).to match_array [variant_1]
      end
    end

    context "with no sku but given option value ids" do
      let(:sku) { "" }

      it "finds the correct variants" do
        subject
        expect(assigns(:variants)).to match_array [variant_1, variant_2]
      end
    end

    context "with no sku or option value ids" do
      let(:sku) { "" }
      let(:option_value_ids) { [""] }

      it "finds all variants associated to the product" do
        subject
        expect(assigns(:variants)).to match_array product.variants
      end
    end
  end
end
