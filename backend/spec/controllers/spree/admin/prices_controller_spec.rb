require 'spec_helper'

describe Spree::Admin::PricesController, type: :controller do
  stub_authorization!

  describe "#index" do
    subject { spree_get :index, product_id: product.slug }

    let(:product) { create(:product) }

    context "for a product with prices" do
      it "succeeds" do
        expect(response).to be_ok
      end
    end
  end
end
