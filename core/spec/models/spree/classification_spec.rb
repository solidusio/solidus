# frozen_string_literal: true

require 'rails_helper'

module Spree
  RSpec.describe Classification, type: :model do
    # Regression test for https://github.com/spree/spree/issues/3494
    it "cannot link the same taxon to the same product more than once" do
      product = create(:product)
      taxon = create(:taxon)
      add_taxon = lambda { product.taxons << taxon }
      add_taxon.call
      expect(add_taxon).to raise_error(ActiveRecord::RecordInvalid)
    end

    let(:taxon_with_5_products) do
      products = []
      5.times do
        products << create(:base_product)
      end

      create(:taxon, products: products)
    end

    def positions_to_be_valid(taxon)
      positions = taxon.reload.classifications.map(&:position)
      expect(positions).to eq((1..taxon.classifications.count).to_a)
    end

    it "has a valid fixtures" do
      expect positions_to_be_valid(taxon_with_5_products)
      expect(Spree::Classification.count).to eq 5
    end

    context "removing product from taxon" do
      before :each do
        element = taxon_with_5_products.products[1]
        expect(element.classifications.first.position).to eq(2)
        taxon_with_5_products.products.destroy(element)
      end

      it "resets positions" do
        expect positions_to_be_valid(taxon_with_5_products)
      end
    end

    context "Discard'ing a product" do
      before :each do
        element = taxon_with_5_products.products[1]
        expect(element.classifications.first.position).to eq(2)
        element.discard
      end

      it "resets positions" do
        expect positions_to_be_valid(taxon_with_5_products)
      end
    end

    context "replacing taxon's products" do
      before :each do
        products = taxon_with_5_products.products.to_a
        products.pop(1)
        taxon_with_5_products.products = products
        taxon_with_5_products.save!
      end

      it "resets positions" do
        expect positions_to_be_valid(taxon_with_5_products)
      end
    end

    context "removing taxon from product" do
      before :each do
        element = taxon_with_5_products.products[1]
        element.taxons.destroy(taxon_with_5_products)
        element.save!
      end

      it "resets positions" do
        expect positions_to_be_valid(taxon_with_5_products)
      end
    end

    context "replacing product's taxons" do
      before :each do
        element = taxon_with_5_products.products[1]
        element.taxons = []
        element.save!
      end

      it "resets positions" do
        expect positions_to_be_valid(taxon_with_5_products)
      end
    end

    context "destroying classification" do
      before :each do
        classification = taxon_with_5_products.classifications[1]
        classification.destroy
      end

      it "resets positions" do
        expect positions_to_be_valid(taxon_with_5_products)
      end
    end

    it "touches the product" do
      taxon = taxon_with_5_products
      classification = taxon.classifications.first
      product = classification.product
      product.update_columns(updated_at: 1.day.ago)
      expect {
        classification.touch
      }.to change { product.reload.updated_at }
    end

    it "touches the taxon" do
      taxon = taxon_with_5_products
      classification = taxon.classifications.first
      taxon.update_columns(updated_at: 1.day.ago)
      expect {
        classification.touch
      }.to change { taxon.reload.updated_at }
    end
  end
end
