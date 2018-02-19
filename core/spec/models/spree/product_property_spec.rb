# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::ProductProperty, type: :model do
  context "touching" do
    let(:product_property) { create(:product_property) }
    let(:product) { product_property.product }

    before do
      product.update_columns(updated_at: 1.day.ago)
    end

    subject { product_property.touch }

    it "touches the product" do
      expect { subject }.to change { product.reload.updated_at }
    end
  end
end
