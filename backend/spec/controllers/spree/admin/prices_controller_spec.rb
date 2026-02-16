# frozen_string_literal: true

require 'spec_helper'

describe Spree::Admin::PricesController do
  stub_authorization!

  let!(:product) { create(:product) }

  describe '#index' do
    context "when only given a product" do
      let(:product) { create(:product) }

      let!(:deleted_master_price) { create(:price, variant: product.master).tap(&:destroy!) }

      subject { get :index, params: { product_id: product.slug } }

      it { is_expected.to be_successful }

      it 'assigns usable instance variables' do
        subject
        expect(assigns(:search)).to be_a(Ransack::Search)
        expect(assigns(:variant_prices)).to be_empty
        expect(assigns(:master_prices)).to eq(product.prices.for_master)
        expect(assigns(:master_prices)).to_not include(deleted_master_price)
        expect(assigns(:product)).to eq(product)
      end
    end

    context "when given a product and a variant" do
      let(:variant) { create(:variant) }
      let(:product) { variant.product }

      let!(:deleted_variant_price) { create(:price, variant:).tap(&:destroy!) }

      subject { get :index, params: { product_id: product.slug, variant_id: variant.id } }

      it { is_expected.to be_successful }

      it 'assigns usable instance variables' do
        subject
        expect(assigns(:search)).to be_a(Ransack::Search)
        expect(assigns(:variant_prices)).to eq(product.prices.for_variant)
        expect(assigns(:master_prices)).to eq(product.prices.for_master)
        expect(assigns(:variant_prices)).to include(variant.default_price)
        expect(assigns(:variant_prices)).to_not include(deleted_variant_price)
        expect(assigns(:product)).to eq(product)
      end
    end
    context "existent product id not given" do
      subject { get :index, params: { product_id: 'non-existent-product' } }

      it "cannot find non-existent product" do
        subject
        expect(response).to redirect_to(spree.admin_products_path)
        expect(flash[:error]).to eql("Product is not found")
      end
    end
  end
end
