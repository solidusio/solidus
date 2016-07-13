require 'spec_helper'

describe Spree::Admin::PricesController do
  stub_authorization!

  let!(:product) { create(:product) }

  describe '#index' do
    context "when only given a product" do
      let(:product) { create(:product) }

      subject { get :index, product_id: product.slug }

      it { is_expected.to be_success }

      it 'assigns usable instance variables' do
        subject
        expect(assigns(:search)).to be_a(Ransack::Search)
        expect(assigns(:prices)).to eq(product.prices)
        expect(assigns(:product)).to eq(product)
      end
    end

    context "when given a product and a variant" do
      let(:variant) { create(:variant) }
      let(:product) { variant.product }

      subject { get :index, product_id: product.slug, variant_id: variant.id }

      it { is_expected.to be_success }

      it 'assigns usable instance variables' do
        subject
        expect(assigns(:search)).to be_a(Ransack::Search)
        expect(assigns(:prices)).to eq(product.prices)
        expect(assigns(:prices)).to include(variant.default_price)
        expect(assigns(:product)).to eq(product)
      end
    end
  end
end
