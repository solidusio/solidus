require 'spec_helper'

describe Spree::ProductProperty, type: :model do
  context "touching" do
    let(:product_property) { create(:product_property) }
    let(:product) { product_property.product }

    subject { product_property.touch }

    it "touches the product" do
      expect { subject }.to change { product.reload.updated_at }
    end
  end
end
