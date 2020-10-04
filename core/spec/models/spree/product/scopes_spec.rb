# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Product scopes", type: :model do
  let!(:product) { create(:product) }

  context "A product assigned to parent and child taxons" do
    before do
      @taxonomy = create(:taxonomy)
      @root_taxon = @taxonomy.root

      @parent_taxon = create(:taxon, name: 'Parent', taxonomy_id: @taxonomy.id, parent: @root_taxon)
      @child_taxon = create(:taxon, name: 'Child 1', taxonomy_id: @taxonomy.id, parent: @parent_taxon)
      @parent_taxon.reload # Need to reload for descendents to show up

      product.taxons << @parent_taxon
      product.taxons << @child_taxon
    end

    it "calling Product.in_taxon returns products in child taxons" do
      product.taxons -= [@child_taxon]
      expect(product.taxons.count).to eq(1)

      expect(Spree::Product.in_taxon(@parent_taxon)).to include(product)
    end

    it "calling Product.in_taxon should not return duplicate records" do
      expect(Spree::Product.in_taxon(@parent_taxon).to_a.size).to eq(1)
    end

    context 'orders products based on their ordering within the classifications' do
      let(:other_taxon) { create(:taxon, products: [product]) }
      let!(:product_2) { create(:product, taxons: [@child_taxon, other_taxon]) }

      it 'by initial ordering' do
        expect(Spree::Product.in_taxon(@child_taxon)).to eq([product, product_2])
        expect(Spree::Product.in_taxon(other_taxon)).to eq([product, product_2])
      end

      it 'after ordering changed' do
        [@child_taxon, other_taxon].each do |taxon|
          Spree::Classification.find_by(taxon: taxon, product: product).insert_at(2)
          expect(Spree::Product.in_taxon(taxon)).to eq([product_2, product])
        end
      end
    end
  end

  context "property scopes" do
    let(:name) { "A proper tee" }
    let(:value) { "A proper value" }
    let!(:property) { create(:property, name: name) }

    before do
      product.properties << property
      product.product_properties.find_by(property: property).update_column(:value, value)
    end

    context "with_property" do
      let(:with_property) { Spree::Product.method(:with_property) }
      it "finds by a property's name" do
        expect(with_property.call(name).count).to eq(1)
      end

      it "doesn't find any properties with an unknown name" do
        expect(with_property.call("fake").count).to eq(0)
      end

      it "finds by a property" do
        expect(with_property.call(property).count).to eq(1)
      end

      it "finds by an id" do
        expect(with_property.call(property.id).count).to eq(1)
      end

      it "cannot find a property with an unknown id" do
        expect(with_property.call(0).count).to eq(0)
      end
    end

    context "with_property_value" do
      let(:with_property_value) { Spree::Product.method(:with_property_value) }
      it "finds by a property's name" do
        expect(with_property_value.call(name, value).count).to eq(1)
      end

      it "cannot find by an unknown property's name" do
        expect(with_property_value.call("fake", value).count).to eq(0)
      end

      it "cannot find with a name by an incorrect value" do
        expect(with_property_value.call(name, "fake").count).to eq(0)
      end

      it "finds by a property" do
        expect(with_property_value.call(property, value).count).to eq(1)
      end

      it "cannot find with a property by an incorrect value" do
        expect(with_property_value.call(property, "fake").count).to eq(0)
      end

      it "finds by an id with a value" do
        expect(with_property_value.call(property.id, value).count).to eq(1)
      end

      it "cannot find with an invalid id" do
        expect(with_property_value.call(0, value).count).to eq(0)
      end

      it "cannot find with an invalid value" do
        expect(with_property_value.call(property.id, "fake").count).to eq(0)
      end
    end
  end

  describe '.available' do
    context "a product with past available_on" do
      let!(:product) { create(:product, available_on: 1.day.ago) }

      it "includes the product" do
        expect(Spree::Product.available).to match_array([product])
      end

      context "with no master price" do
        before { product.master.prices.delete_all }

        it "doesn't include the product" do
          expect(Spree::Product.available).to match_array([])
        end
      end

      context "with soft-deleted master price" do
        before { product.master.prices.discard_all }

        it "doesn't include the product" do
          expect(Spree::Product.available).to match_array([])
        end
      end

      context "with multiple prices" do
        let!(:second_price) { create(:price, variant: product.master) }

        it "includes the product only once" do
          expect(Spree::Product.available).to match_array([product])
        end

        it "has a count of 1" do
          expect(Spree::Product.available.count).to eq(1)
        end
      end
    end

    context "a product with future available_on" do
      let!(:product) { create(:product, available_on: 1.day.from_now) }

      it "doesn't include the product" do
        expect(Spree::Product.available).to match_array([])
      end
    end
  end
end
