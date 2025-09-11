# frozen_string_literal: true

require "rails_helper"

module ThirdParty
  class Extension < Spree::Base
    # nasty hack so we don't have to create a table to back this fake model
    self.table_name = "spree_products"
  end
end

RSpec.describe Spree::Product, type: :model do
  context "product instance" do
    let(:product) { create(:product) }
    let(:variant) { create(:variant, product:) }

    context "#duplicate" do
      before do
        allow(product).to receive_messages taxons: [create(:taxon)]
      end

      it "duplicates product" do
        clone = product.duplicate
        expect(clone.name).to eq("COPY OF " + product.name)
        expect(clone.master.sku).to eq("COPY OF " + product.master.sku)
        expect(clone.taxons).to eq(product.taxons)
        expect(clone.images.size).to eq(product.images.size)
      end

      it "calls #duplicate_extra", partial_double_verification: false do
        expect_any_instance_of(Spree::Product).to receive(:duplicate_extra) do |product, old_product|
          product.name = old_product.name.reverse
        end

        clone = product.duplicate
        expect(clone.name).to eq(product.name.reverse)
      end
    end

    describe "#save" do
      before { product.update_columns(updated_at: 1.day.ago) }
      subject { product.save! }

      shared_examples "a change occurred" do
        it "should change updated_at" do
          expect { subject }.to change { product.updated_at }
        end

        it "should touch taxons" do
          taxon = create(:taxon, product_ids: [product.id])
          taxon.update_columns(updated_at: 1.day.ago)
          product.taxons.reload
          expect { subject }.to change { taxon.reload.updated_at }
        end
      end

      shared_examples "no change occurred" do
        it "should not change updated_at" do
          expect { subject }.not_to change { product.updated_at }
        end

        it "should not touch taxons" do
          taxon = create(:taxon, products: [product])
          taxon.update_columns(updated_at: 1.day.ago)
          product.taxons.reload
          expect { subject }.not_to change { taxon.reload.updated_at }
        end
      end

      context "when nothing has changed" do
        it_behaves_like "no change occurred"
      end

      context "when the product itself was changed" do
        before do
          product.name = "Perri-air"
        end

        it_behaves_like "a change occurred"
      end

      context "when master variant changed" do
        before do
          product.master.sku = "Something changed"
        end

        it_behaves_like "a change occurred"

        it "saves the master" do
          product.save!
          expect(product.reload.master.sku).to eq "Something changed"
        end
      end

      context "when master default price changed" do
        before do
          master = product.master
          master.default_price.price = 11
          master.save!
          product.update_columns(updated_at: 1.day.ago)
          product.master.default_price.price = 12
        end

        it_behaves_like "a change occurred"

        it "saves the default_price" do
          product.save!
          expect(product.reload.master.default_price.price).to eq 12
        end
      end

      context "when master variant attributes change" do
        before do
          product.master.gtin = "1234567890123"
          product.master.condition = "new"
        end

        it_behaves_like "a change occurred"

        it "saves the master with updated gtin and condition" do
          product.save!
          expect(product.reload.master.gtin).to eq "1234567890123"
          expect(product.reload.master.condition).to eq "new"
        end
      end
    end

    context "product has no variants" do
      context "#discard" do
        it "should set deleted_at value" do
          product.discard
          expect(product.deleted_at).not_to be_nil
          expect(product.master.reload.deleted_at).not_to be_nil
        end
      end
    end

    context "product has variants" do
      before do
        create(:variant, product:)
      end

      context "#discard" do
        it "should set deleted_at value" do
          product.discard
          expect(product.deleted_at).not_to be_nil
          expect(product.variants_including_master.reload).to all(be_discarded)
        end
      end
    end

    context "#price" do
      # Regression test for https://github.com/spree/spree/issues/1173
      it "strips non-price characters" do
        product.price = "$10"
        expect(product.price).to eq(10.0)
      end
    end

    context "#display_price" do
      before { product.price = 10.55 }

      it "shows the amount" do
        expect(product.display_price.to_s).to eq("$10.55")
      end

      context "with currency set to JPY" do
        before do
          product.master.default_price.update!(currency: "JPY")
          stub_spree_preferences(currency: "JPY")
        end

        it "displays the currency in yen" do
          expect(product.display_price.to_s).to eq("¥11")
        end
      end
    end

    describe "#available?" do
      context "if available_on is in the past" do
        let(:product) { build(:product, available_on: 1.day.ago) }

        it "should be available" do
          expect(product).to be_available
        end
      end

      context "if available_on is nil" do
        let(:product) { build(:product, available_on: nil) }

        it "should not be available" do
          expect(product).not_to be_available
        end
      end

      context "if available_on is in the future" do
        let(:product) { build(:product, available_on: 1.day.from_now) }

        it "should not be available" do
          expect(product).not_to be_available
        end
      end

      context "if discontinue_on is in the past" do
        let(:product) { build(:product, discontinue_on: 1.day.ago) }

        it "should not be available" do
          expect(product).not_to be_available
        end
      end

      context "if discontinue_on is nil" do
        let(:product) { build(:product, discontinue_on: nil) }

        it "should be available" do
          expect(product).to be_available
        end
      end

      context "if discontinue_on is in the future" do
        let(:product) { build(:product, discontinue_on: 1.day.from_now) }

        it "should be available" do
          expect(product).to be_available
        end
      end

      context "if deleted" do
        let(:product) { build(:product, deleted_at: 1.day.ago) }

        it "should not be available" do
          expect(product).not_to be_available
        end
      end
    end

    describe "#discontinued?" do
      subject { product.discontinued? }

      context "if discontinue_on is in the past" do
        let(:product) { build(:product, discontinue_on: 1.day.ago) }

        it { is_expected.to be(true) }
      end

      context "if discontinue_on is nil" do
        let(:product) { build(:product, discontinue_on: nil) }

        it { is_expected.to be(false) }
      end

      context "if discontinue_on is in the future" do
        let(:product) { build(:product, discontinue_on: 1.day.from_now) }

        it { is_expected.to be(false) }
      end
    end

    context "variants_and_option_values_for" do
      let!(:high) { create(:variant, product:) }
      let!(:low) { create(:variant, product:) }

      context "when one product does not have option values" do
        before { high.option_values.destroy_all }

        it "returns only variants with option values" do
          expect(product.variants_and_option_values_for).to eq([low])
        end
      end

      context "when asking with different pricing options" do
        let(:pricing_options) { Spree::Config.pricing_options_class.new(currency: "EUR") }

        before do
          low.prices.create(amount: 99.00, currency: "EUR")
        end

        it "returns only variants which have matching prices" do
          expect(product.variants_and_option_values_for).to contain_exactly(low, high)
          expect(product.variants_and_option_values_for(pricing_options)).to contain_exactly(low)
        end
      end

      context "when a variant has a fallback price" do
        before do
          low.prices.create(country_iso: nil)
        end

        it "returns that variant once" do
          expect(product.variants_and_option_values_for.length).to eq(2)
        end
      end
    end

    describe "#variant_option_values_by_option_type" do
      let(:size) { create(:option_type, name: "size") }
      let(:length) { create(:option_type, name: "length") }
      let(:product) { create(:product, option_types: [size, length]) }
      let(:size_small) { create(:option_value, name: "small", option_type: size, position: 3) }
      let(:size_medium) { create(:option_value, name: "medium", option_type: size, position: 1) }
      let(:size_large) { create(:option_value, name: "large", option_type: size, position: 2) }
      let!(:variant) { create(:variant, product:, option_values: [size_small, size_medium]) }

      subject { product.variant_option_values_by_option_type }

      it "returns the option values associated with the product's variants grouped by option type" do
        expect(subject).to eq({size => [size_medium, size_small]})
      end
    end

    describe "#find_variant_property_rule" do
      let(:option_value) { create(:option_value) }

      subject { product.find_variant_property_rule([option_value.id]) }

      context "a matching rule exists" do
        let!(:rule) do
          create(:variant_property_rule, product:, option_value:)
        end

        it "returns the rule" do
          expect(subject).to eq rule
        end
      end

      context "a matching rule doesn't exist" do
        it "returns nil" do
          expect(subject).to be_nil
        end
      end
    end

    describe "Variants sorting" do
      let(:master) { product.master }

      let!(:second) { create(:variant, product:) }
      let!(:third) { create(:variant, product:) }
      let!(:first) { create(:variant, product:) }

      before do
        first.update_columns(position: 2)
        second.update_columns(position: 3)
        third.update_columns(position: 4)
      end

      context "without master variant" do
        it "sorts variants by position" do
          expect(product.variants).to eq([first, second, third])
        end
      end

      context "with master variant" do
        it "sorts variants by position" do
          expect(product.variants_including_master).to eq([master, first, second, third])
        end
      end
    end

    context "has stock movements" do
      let(:product) { create(:product) }
      let(:variant) { product.master }
      let(:stock_item) { variant.stock_items.first }

      it "doesnt raise ReadOnlyRecord error" do
        Spree::StockMovement.create!(stock_item:, quantity: 1)
        product.discard
      end
    end

    # Regression test for https://github.com/spree/spree/issues/3737
    context "has stock items" do
      let(:product) { create(:product) }
      it "can retrieve stock items" do
        expect(product.master.stock_items.first).not_to be_nil
        expect(product.stock_items.first).not_to be_nil
      end
    end

    context "slugs" do
      it "normalizes slug on update validation" do
        product.slug = "hey//joe"
        product.valid?
        expect(product.slug).not_to match "/"
      end

      it "renames slug on destroy" do
        old_slug = product.slug
        product.discard
        expect(old_slug).to_not eq product.slug
      end

      it "validates slug uniqueness" do
        existing_product = product
        new_product = create(:product)
        new_product.slug = existing_product.slug

        expect(new_product.valid?).to eq false
      end

      it "falls back to 'name-sku' for slug if regular name-based slug already in use" do
        product1 = build(:product)
        product1.name = "test"
        product1.sku = "123"
        product1.save!

        product2 = build(:product)
        product2.name = "test"
        product2.sku = "456"
        product2.save!

        expect(product2.slug).to eq "test-456"
      end
    end

    describe "#discard" do
      let(:product) { create(:product, slug: "my-awesome-product") }

      it "destroys related associations" do
        create(:variant, product:)
        product.option_types = [create(:option_type)]
        product.master.images = [create(:image)]
        product.taxons = [create(:taxon)]
        product.properties = [create(:property)]

        product.discard

        product.reload
        expect(product.option_types).to be_empty
        expect(product.images).to be_empty
        expect(product.taxons).to be_empty
        expect(product.properties).to be_empty
      end

      it "replaces the slug" do
        product.discard

        expect(product.slug).to match(/\A\d+_my-awesome-product\z/)

        # Ensure a new product can be created with the slug
        new_product = create(:product, slug: "my-awesome-product")
        expect(new_product.slug).to eq("my-awesome-product")
      end
    end

    context "associations" do
      describe "product_option_types" do
        context "with no existing option types" do
          before { product.update_columns(updated_at: 1.day.ago) }

          it "touches the product instance when an option type is added" do
            expect {
              product.product_option_types.create(option_type: create(:option_type, name: "new-option-type"))
            }.to change { product.reload.updated_at }
          end
        end

        context "with an existing option type" do
          before do
            product.product_option_types.create(option_type: create(:option_type, name: "new-option-type"))
            product.update_columns(updated_at: 1.day.ago)
          end

          it "touches product instance when an option type is removed" do
            expect {
              product.product_option_types = []
            }.to change { product.reload.updated_at }
          end
        end
      end

      describe "primary_taxon" do
        it "should belong to primary_taxon" do
          expect(Spree::Product.reflect_on_association(:primary_taxon).macro).to eq(:belongs_to)
        end

        it "should be optional" do
          association = Spree::Product.reflect_on_association(:primary_taxon)
          expect(association.options[:optional]).to be(true)
        end

        it "should have a class_name of Spree::Taxon" do
          association = Spree::Product.reflect_on_association(:primary_taxon)
          expect(association.class_name).to eq("Spree::Taxon")
        end
      end
    end
  end

  context "properties" do
    let(:product) { create(:product) }

    it "should properly assign properties" do
      product.set_property("the_prop", "value1")
      expect(product.property("the_prop")).to eq("value1")

      product.set_property("the_prop", "value2")
      expect(product.property("the_prop")).to eq("value2")
    end

    it "should not create duplicate properties when set_property is called" do
      expect {
        product.set_property("the_prop", "value2")
        product.save
        product.reload
      }.not_to change(product.properties, :length)

      expect {
        product.set_property("the_prop_new", "value")
        product.save
        product.reload
        expect(product.property("the_prop_new")).to eq("value")
      }.to change { product.properties.length }.by(1)
    end

    # Regression test for https://github.com/spree/spree/issues/2455
    it "should not overwrite properties' presentation names" do
      Spree::Property.where(name: "foo").first_or_create!(presentation: "Foo's Presentation Name")
      product.set_property("foo", "value1")
      product.set_property("bar", "value2")
      expect(Spree::Property.where(name: "foo").first.presentation).to eq("Foo's Presentation Name")
      expect(Spree::Property.where(name: "bar").first.presentation).to eq("bar")
    end
  end

  context "#possible_promotions" do
    let(:product) { create(:product) }

    subject { product.possible_promotions }

    it "calls the configured promotion advertiser class" do
      expect(Spree::Config.promotions.advertiser_class).to receive(:for_product).with(product)
      subject
    end
  end

  context "#images" do
    let(:product) { create(:product) }
    let(:image) { File.open(Spree::Core::Engine.root.join("lib", "spree", "testing_support", "fixtures", "blank.jpg")) }
    let(:params) { {viewable_id: product.master.id, viewable_type: "Spree::Variant", attachment: image, alt: "position 2", position: 2} }

    before do
      Spree::Image.create(params)
      Spree::Image.create(params.merge({alt: "position 1", position: 1}))
      Spree::Image.create(params.merge({viewable_type: "ThirdParty::Extension", alt: "position 1", position: 2}))
    end

    it "only looks for variant images" do
      expect(product.images.size).to eq(2)
    end

    it "should be sorted by position" do
      expect(product.images.pluck(:alt)).to eq(["position 1", "position 2"])
    end
  end

  # Regression tests for https://github.com/spree/spree/issues/2352
  context "classifications and taxons" do
    it "is joined through classifications" do
      reflection = Spree::Product.reflect_on_association(:taxons)
      expect(reflection.options[:through]).to eq(:classifications)
    end

    it "will delete all classifications" do
      reflection = Spree::Product.reflect_on_association(:classifications)
      expect(reflection.options[:dependent]).to eq(:delete_all)
    end
  end

  context "#total_on_hand" do
    it "should be infinite if track_inventory_levels is false" do
      stub_spree_preferences(track_inventory_levels: false)
      expect(build(:product, variants_including_master: [build(:master_variant)]).total_on_hand).to eql(Float::INFINITY)
    end

    it "should be infinite if variant is on demand" do
      stub_spree_preferences(track_inventory_levels: true)
      expect(build(:product, variants_including_master: [build(:on_demand_master_variant)]).total_on_hand).to eql(Float::INFINITY)
    end

    it "should return sum of stock items count_on_hand" do
      product = create(:product)
      product.stock_items.first.set_count_on_hand 5
      product.variants_including_master.reload # force load association
      expect(product.total_on_hand).to eql(5)
    end

    it "should return sum of stock items count_on_hand when variants_including_master is not loaded" do
      product = create(:product)
      product.stock_items.first.set_count_on_hand 5
      expect(product.reload.total_on_hand).to eql(5)
    end
  end

  # Regression spec for https://github.com/spree/spree/issues/5588
  context "#validate_master when duplicate SKUs entered" do
    let!(:first_product) { create(:product, sku: "a-sku") }
    let(:second_product) { build(:product, sku: "a-sku") }

    subject { second_product }
    it { is_expected.to be_invalid }
  end

  describe ".new" do
    let(:product) { Spree::Product.new(attributes) }

    shared_examples "new product with master" do
      it "initializes master correctly" do
        expect(product.master.is_master).to be true
        expect(product.master.product).to be product
      end
    end

    context "no attributes" do
      let(:attributes) { {} }
      it_behaves_like "new product with master"
    end

    context "initializing with variant attributes" do
      let(:attributes) { {sku: "FOO"} }

      it_behaves_like "new product with master"

      it "initializes the variant with the correct attributes" do
        expect(product.master.sku).to eq "FOO"
        expect(product.sku).to eq "FOO"
      end
    end
  end

  describe "#gallery" do
    let(:product) { Spree::Product.new }
    subject { product.gallery }

    it "responds to #images" do
      expect(subject).to respond_to(:images)
    end
  end

  describe ".sort_by_master_default_price_amount_asc" do
    it "returns first those which default price is lower" do
      product_1 = create(:product, price: 10)
      product_2 = create(:product, price: 5)

      result = described_class.sort_by_master_default_price_amount_asc

      expect(result).to eq([product_2, product_1])
    end
  end

  describe ".sort_by_master_default_price_amount_desc" do
    it "returns first those which default price is higher" do
      product_1 = create(:product, price: 10)
      product_2 = create(:product, price: 5)

      result = described_class.sort_by_master_default_price_amount_desc

      expect(result).to eq([product_1, product_2])
    end
  end

  describe "ransack :option_values_id_in" do
    it "filters products based on option values of their variants" do
      product_1 = create(:product)
      option_value_1 = create(:option_value)
      create(:variant, product: product_1, option_values: [option_value_1])

      result = Spree::Product.ransack(option_values_id_in: [option_value_1.id]).result
      expect(result).to contain_exactly(product_1)
    end

    it "returns multiple products for the same option value" do
      product_1 = create(:product)
      product_2 = create(:product)
      option_value_1 = create(:option_value)
      create(:variant, product: product_1, option_values: [option_value_1])
      create(:variant, product: product_2, option_values: [option_value_1])

      result = Spree::Product.ransack(option_values_id_in: [option_value_1.id]).result
      expect(result).to contain_exactly(product_1, product_2)
    end

    it "returns no products if there is no match" do
      non_existing_option_value_id = 99999
      result = Spree::Product.ransack(option_values_id_in: [non_existing_option_value_id]).result
      expect(result).to be_empty
    end

    it "returns products that match any of the provided option value IDs" do
      product_1 = create(:product)
      product_2 = create(:product)
      option_value_1 = create(:option_value)
      option_value_2 = create(:option_value)
      create(:variant, product: product_1, option_values: [option_value_1])
      create(:variant, product: product_2, option_values: [option_value_2])

      result = Spree::Product.ransack(option_values_id_in: [option_value_1.id, option_value_2.id]).result
      expect(result).to contain_exactly(product_1, product_2)
    end

    it "doesn't return products that have other option values not in the query" do
      product_1 = create(:product)
      product_2 = create(:product)
      option_value_1 = create(:option_value)
      option_value_2 = create(:option_value)
      create(:variant, product: product_1, option_values: [option_value_1])
      create(:variant, product: product_2, option_values: [option_value_2])

      result = Spree::Product.ransack(option_values_id_in: [option_value_1.id]).result
      expect(result).not_to include(product_2)
    end
  end

  describe "ransack scopes" do
    context "available scope" do
      subject { described_class.ransack(available: true).result }

      let!(:available_product) { create(:product) }
      let!(:not_available_product) { create(:product, available_on: Time.zone.tomorrow) }

      it "is included" do
        expect(subject).to match_array([available_product])
      end
    end
  end

  describe "inventory tracking" do
    let(:product) { build(:product) }

    describe "#track_inventory=" do
      it "delegates to master variant" do
        expect(product.master).to receive(:track_inventory=).with(true)
        product.track_inventory = true
      end
    end

    describe "#track_inventory" do
      it "delegates to master variant" do
        expect(product.master).to receive(:track_inventory) { true }
        expect(product.track_inventory).to be(true)
      end
    end
  end

  it "is valid with or without a primary_taxon" do
    product_with_taxon = create(:product, primary_taxon: create(:taxon))

    product_without_taxon = create(:product, primary_taxon: nil)

    expect(product_with_taxon).to be_valid
    expect(product_without_taxon).to be_valid
  end
end
