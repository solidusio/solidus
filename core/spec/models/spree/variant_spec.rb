# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Variant, type: :model do
  it { is_expected.to be_invalid }

  let!(:variant) { create(:variant) }

  describe 'delegates' do
    let(:product) { build(:product) }
    let(:variant) { build(:variant, product: product) }

    it 'discontinue_on to product' do
      expect(product).to receive(:discontinue_on)
      variant.discontinue_on
    end

    it 'discontinued? to product' do
      expect(product).to receive(:discontinued?)
      variant.discontinued?
    end
  end

  context "validations" do
    it "should validate price is greater than 0" do
      variant = build(:variant, price: -1)
      expect(variant).to be_invalid
    end

    it "should validate price is 0" do
      variant.price = 0
      expect(variant).to be_valid
    end

    it "should require a product" do
      expect(variant).to be_valid
      variant.product = nil
      expect(variant).to be_invalid
      variant.price = nil
      expect(variant).to be_invalid
    end

    it "should have a unique sku" do
      variant_with_same_sku = build(:variant, sku: variant.sku)
      expect(variant_with_same_sku).to be_invalid
    end

    context "if it is a master variant" do
      let(:product) { create(:product) }
      subject(:variant) { product.master }

      before do
        variant.price = nil
      end

      it "is invalid without a price" do
        variant.valid?
        expect(subject.errors.full_messages).to include("Price Must supply price for variant or master.price for product.")
      end

      context "if it has a price" do
        before do
          variant.price = 10
        end

        it { is_expected.to be_valid }
      end
    end
  end

  context "after create" do
    let!(:product) { create(:product) }

    it "propagate to stock items" do
      expect_any_instance_of(Spree::StockLocation).to receive(:propagate_variant)
      product.variants.create!
    end

    context "stock location has disable propagate all variants" do
      before { Spree::StockLocation.update_all propagate_all_variants: false }

      it "propagate to stock items" do
        expect_any_instance_of(Spree::StockLocation).not_to receive(:propagate_variant)
        product.variants.create!
      end
    end

    describe 'mark_master_out_of_stock' do
      before do
        product.master.stock_items.first.set_count_on_hand(5)
      end
      context 'when product is created without variants but with stock' do
        it { expect(product.master).to be_in_stock }
      end

      context 'when a variant is created' do
        before(:each) do
          product.variants.create!
        end

        it { expect(product.master).to_not be_in_stock }
      end
    end

    context "when several countries have VAT" do
      let(:germany) { create(:country, iso: "DE") }
      let(:denmark) { create(:country, iso: "DK") }
      let(:france) { create(:country, iso: "FR") }

      let(:high_vat_zone) { create(:zone, countries: [germany, denmark]) }
      let(:low_vat_zone) { create(:zone, countries: [france]) }

      let(:tax_category) { create(:tax_category) }

      let!(:high_vat) { create(:tax_rate, included_in_price: true, amount: 0.25, zone: high_vat_zone, tax_categories: [tax_category]) }
      let!(:low_vat) { create(:tax_rate, included_in_price: true, amount: 0.15, zone: low_vat_zone, tax_categories: [tax_category]) }

      let(:product) { build(:product, tax_category: tax_category) }

      subject(:new_variant) { build(:variant, price: 15) }

      it "creates the appropriate prices for them" do
        product.variants << new_variant
        product.save!
        expect(new_variant.prices.find_by(country_iso: "FR").amount).to eq(17.25)
        expect(new_variant.prices.find_by(country_iso: "DE").amount).to eq(18.75)
        expect(new_variant.prices.find_by(country_iso: "DK").amount).to eq(18.75)
        expect(new_variant.prices.find_by(country_iso: nil).amount).to eq(15.00)
        # default price + FR, DE, DK
        expect(new_variant.prices.count).to eq(4)
      end

      context "when the products price changes" do
        context "and rebuild_vat_prices is set to true" do
          subject { variant.update(price: 99, rebuild_vat_prices: true, tax_category: tax_category) }

          it "creates new appropriate prices for this variant" do
            expect { subject }.to change { Spree::Price.count }.by(3)
            expect(variant.prices.find_by(country_iso: "FR").amount).to eq(113.85)
            expect(variant.prices.find_by(country_iso: "DE").amount).to eq(123.75)
            expect(variant.prices.find_by(country_iso: "DK").amount).to eq(123.75)
            expect(variant.prices.find_by(country_iso: nil).amount).to eq(99.00)
          end
        end

        context "and rebuild_vat_prices is not set" do
          subject { variant.update(price: 99, tax_category: tax_category) }

          it "does not create new prices" do
            expect { subject }.not_to change { Spree::Price.count }
          end
        end
      end
    end
  end

  context "product has other variants" do
    describe "option value accessors" do
      before {
        @multi_variant = FactoryBot.create :variant, product: variant.product
        variant.product.reload
      }

      let(:multi_variant) { @multi_variant }

      it "should set option value" do
        expect(multi_variant.option_value('media_type')).to be_nil

        multi_variant.set_option_value('media_type', 'DVD')
        expect(multi_variant.option_value('media_type')).to eql 'DVD'

        multi_variant.set_option_value('media_type', 'CD')
        expect(multi_variant.option_value('media_type')).to eql 'CD'
      end

      it "should not duplicate associated option values when set multiple times" do
        multi_variant.set_option_value('media_type', 'CD')

        expect {
         multi_variant.set_option_value('media_type', 'DVD')
        }.to_not change(multi_variant.option_values, :count)

        expect {
          multi_variant.set_option_value('coolness_type', 'awesome')
        }.to change(multi_variant.option_values, :count).by(1)
      end

      context "setting using #options=" do
        it "should set option value" do
          expect(multi_variant.option_value('media_type')).to be_nil

          multi_variant.options = [{ name: "media_type", value: 'DVD' }]
          expect(multi_variant.option_value('media_type')).to eql 'DVD'

          multi_variant.options = [{ name: "media_type", value: 'CD' }]
          expect(multi_variant.option_value('media_type')).to eql 'CD'
        end
      end

      context "and a variant is soft-deleted" do
        let!(:old_options_text) { variant.options_text }

        before { variant.discard }

        it "still keeps the option values for that variant" do
          expect(variant.reload.options_text).to eq(old_options_text)
        end
      end

      context "and a variant is really deleted" do
        let!(:old_option_values_variant_ids) { variant.option_values_variants.pluck(:id) }

        before { variant.destroy }

        it "leaves no stale records behind" do
          expect(old_option_values_variant_ids).to be_present
          expect(Spree::OptionValuesVariant.where(id: old_option_values_variant_ids)).to be_empty
        end
      end
    end
  end

  context "#cost_price=" do
    it "should use LocalizedNumber.parse" do
      expect(Spree::LocalizedNumber).to receive(:parse).with('1,599.99')
      subject.cost_price = '1,599.99'
    end
  end

  context "#price=" do
    it "should use LocalizedNumber.parse" do
      expect(Spree::LocalizedNumber).to receive(:parse).with('1,599.99')
      subject.price = '1,599.99'
    end
  end

  context "#weight=" do
    it "should use LocalizedNumber.parse" do
      expect(Spree::LocalizedNumber).to receive(:parse).with('1,599.99')
      subject.weight = '1,599.99'
    end
  end

  context "#display_amount" do
    it "returns a Spree::Money" do
      variant.price = 21.22
      expect(variant.display_amount.to_s).to eql "$21.22"
    end
  end

  describe '#default_price' do
    context "when multiple prices are present in addition to a default price" do
      let(:pricing_options_germany) { Spree::Config.pricing_options_class.new(currency: "EUR") }
      let(:pricing_options_united_states) { Spree::Config.pricing_options_class.new(currency: "USD") }

      before do
        variant.prices.create(currency: "EUR", amount: 29.99)
        variant.reload
      end

      it 'the default stays the same' do
        expect(variant.default_price.amount).to eq(19.99)
      end

      it 'displays default price' do
        expect(variant.price_for_options(pricing_options_united_states).money.to_s).to eq("$19.99")
        expect(variant.price_for_options(pricing_options_germany).money.to_s).to eq("€29.99")
      end
    end

    context 'when adding multiple prices' do
      it 'it can reassign a default price' do
        expect(variant.default_price.amount).to eq(19.99)
        variant.prices.create(currency: "USD", amount: 12.12)
        expect(variant.reload.default_price.amount).to eq(12.12)
      end
    end

    it 'prioritizes prices recently updated' do
      variant = create(:variant)
      price = create(:price, variant: variant, currency: 'USD')
      create(:price, variant: variant, currency: 'USD')
      price.touch
      variant.prices.reload

      expect(variant.default_price).to eq(price)
    end

    it 'prioritizes non-persisted prices' do
      variant = create(:variant)
      price = build(:price, currency: 'USD', amount: 1, variant_id: variant.id)
      variant.prices.build(price.attributes)
      create(:price, variant: variant, currency: 'USD', amount: 2)

      expect(variant.default_price.attributes).to eq(price.attributes)
    end
  end

  describe '#default_price_or_build' do
    context 'when default price exists' do
      it 'returns it' do
        price = build(:price, currency: 'USD')
        variant = build(:variant, prices: [price])

        expect(variant.default_price_or_build).to eq(price)
      end
    end

    context 'when default price does not exist' do
      it 'builds and returns it' do
        variant = build(:variant, prices: [], price: nil)

        expect(
          variant.default_price_or_build.attributes.values_at(*described_class.default_price_attributes.keys.map(&:to_s))
        ).to eq(described_class.default_price_attributes.values)
      end
    end
  end

  describe '#has_default_price?' do
    context 'when default price is present and not discarded' do
      it 'returns true' do
        variant = create(:variant, price: 20)

        expect(variant.has_default_price?).to be(true)
      end
    end

    context 'when default price is discarded' do
      it 'returns false' do
        variant = create(:variant, price: 20)

        variant.default_price.discard

        expect(variant.has_default_price?).to be(false)
      end
    end
  end

  describe '#currently_valid_prices' do
    around do |example|
      Spree::Deprecation.silence do
        example.run
      end
    end

    it 'returns prioritized prices' do
      price_1 = create(:price, country: create(:country))
      price_2 = create(:price, country: nil)
      variant = create(:variant, prices: [price_1, price_2])

      result = variant.currently_valid_prices

      expect(
        result.index(price_1) < result.index(price_2)
      ).to be(true)
    end
  end

  context "#cost_currency" do
    context "when cost currency is nil" do
      before { variant.cost_currency = nil }
      it "populates cost currency with the default value on save" do
        variant.save!
        expect(variant.cost_currency).to eql "USD"
      end
    end
  end

  context "#price_selector" do
    subject { variant.price_selector }

    it "returns an instance of a price selector" do
      expect(variant.price_selector).to be_a(Spree::Config.variant_price_selector_class)
    end

    it "is instacached" do
      expect(variant.price_selector.object_id).to eq(variant.price_selector.object_id)
    end
  end

  context "#price_for(price_options)" do
    let(:price_options) { Spree::Config.variant_price_selector_class.pricing_options_class.new }

    it "calls the price selector with the given options object" do
      expect(variant.price_selector).to receive(:price_for).with(price_options)
      variant.price_for(price_options)
    end

    it "returns a Spree::Money object with a deprecation warning", :aggregate_failures do
      expect(Spree::Deprecation).to receive(:warn).
        with(/^price_for is deprecated and will be removed/, any_args)
      expect(variant.price_for(price_options)).to eq Spree::Money.new(19.99)
    end
  end

  context "#price_for_options(price_options)" do
    subject { variant.price_for_options(price_options) }

    let(:price_options) { Spree::Config.variant_price_selector_class.pricing_options_class.new }

    it "delegates to the price_selector" do
      expect(variant.price_selector).to receive(:price_for_options).with(price_options)
      subject
    end

    it "returns a Spree::Price object for the given pricing_options", :aggregate_failures do
      expect(subject).to be_a Spree::Price
      expect(subject.amount).to eq 19.99
    end

    context "when the price_selector does not implement #price_for_options" do
      before do
        allow(variant.price_selector).to receive(:respond_to?).with(:price_for_options).and_return false
      end

      it "returns an unpersisted Spree::Price", :aggregate_failures do
        expect(Spree::Deprecation).to receive(:warn).
          with(/^price_for is deprecated and will be removed/, any_args)
        expect(subject).to be_a Spree::Price
        expect(subject.amount).to eq 19.99
      end
    end
  end

  context "#price_difference_from_master" do
    let(:pricing_options) { Spree::Config.default_pricing_options }

    subject { variant.price_difference_from_master(pricing_options) }

    it "can be called without pricing options" do
      expect(variant.price_difference_from_master).to eq(Spree::Money.new(0))
    end

    context "for the master variant" do
      let(:variant) { create(:product).master }

      it { is_expected.to eq(Spree::Money.new(0, currency: Spree::Config.currency)) }
    end

    context "when both variants have a price" do
      let(:product) { create(:product, price: 25) }
      let(:variant) { create(:variant, product: product, price: 35) }

      it { is_expected.to eq(Spree::Money.new(10, currency: Spree::Config.currency)) }
    end

    context "when the master variant does not have a price" do
      let(:product) { create(:product, price: 25) }
      let(:variant) { create(:variant, product: product, price: 35) }

      before do
        allow(product.master).to receive(:price_for_options).and_return(nil)
      end

      it { is_expected.to be_nil }
    end

    context "when the variant does not have a price" do
      let(:product) { create(:product, price: 25) }
      let(:variant) { create(:variant, product: product, price: 35) }

      before do
        allow(variant).to receive(:price_for_options).and_return(nil)
      end

      it { is_expected.to be_nil }
    end
  end

  context "#price_same_as_master?" do
    context "when the price is the same as the master price" do
      let(:master) { create(:product, price: 10).master }
      let(:variant) { create(:variant, price: 10, product: master.product) }

      subject { variant.price_same_as_master? }

      it { is_expected.to be true }
    end

    context "when the price is different from the master price" do
      let(:master) { create(:product, price: 11).master }
      let(:variant) { create(:variant, price: 10, product: master.product) }

      subject { variant.price_same_as_master? }

      it { is_expected.to be false }
    end

    context "when the master variant does not have a price" do
      let(:master) { create(:product).master }
      let(:variant) { create(:variant, price: 10, product: master.product) }

      before do
        allow(master).to receive(:price_for_options).and_return(nil)
      end

      subject { variant.price_same_as_master? }

      it { is_expected.to be_falsey }
    end

    context "when the variant itself does not have a price" do
      let(:master) { create(:product).master }
      let(:variant) { create(:variant, price: 10, product: master.product) }

      before do
        allow(variant).to receive(:price_for_options).and_return(nil)
      end

      subject { variant.price_same_as_master? }

      it { is_expected.to be_falsey }
    end
  end

  # Regression test for https://github.com/spree/spree/issues/2432
  describe 'options_text' do
    let!(:variant) { create(:variant, option_values: []) }
    let!(:master) { create(:master_variant) }

    before do
      # Order bar than foo
      variant.option_values << create(:option_value, { name: 'Foo', presentation: 'Foo', option_type: create(:option_type, position: 2, name: 'Foo Type', presentation: 'Foo Type') })
      variant.option_values << create(:option_value, { name: 'Bar', presentation: 'Bar', option_type: create(:option_type, position: 1, name: 'Bar Type', presentation: 'Bar Type') })
    end

    it 'should order by bar than foo' do
      expect(variant.options_text).to eql 'Bar Type: Bar, Foo Type: Foo'
    end
  end

  describe 'exchange_name' do
    let!(:variant) { create(:variant, option_values: []) }
    let!(:master) { create(:master_variant) }

    before do
      variant.option_values << create(:option_value, {
                                                     name: 'Foo',
                                                     presentation: 'Foo',
                                                     option_type: create(:option_type, position: 2, name: 'Foo Type', presentation: 'Foo Type')
                                                   })
    end

    context 'master variant' do
      it 'should return name' do
        expect(master.exchange_name).to eql master.name
      end
    end

    context 'variant' do
      it 'should return options text' do
        expect(variant.exchange_name).to eql 'Foo Type: Foo'
      end
    end
  end

  describe 'exchange_name' do
    let!(:variant) { create(:variant, option_values: []) }
    let!(:master) { create(:master_variant) }

    before do
      variant.option_values << create(:option_value, {
                                                     name: 'Foo',
                                                     presentation: 'Foo',
                                                     option_type: create(:option_type, position: 2, name: 'Foo Type', presentation: 'Foo Type')
                                                   })
    end

    context 'master variant' do
      it 'should return name' do
        expect(master.exchange_name).to eql master.name
      end
    end

    context 'variant' do
      it 'should return options text' do
        expect(variant.exchange_name).to eql 'Foo Type: Foo'
      end
    end
  end

  describe 'descriptive_name' do
    let!(:variant) { create(:variant, option_values: []) }
    let!(:master) { create(:master_variant) }

    before do
      variant.option_values << create(:option_value, {
                                                     name: 'Foo',
                                                     presentation: 'Foo',
                                                     option_type: create(:option_type, position: 2, name: 'Foo Type', presentation: 'Foo Type')
                                                   })
    end

    context 'master variant' do
      it 'should return name with Master identifier' do
        expect(master.descriptive_name).to eql master.name + ' - Master'
      end
    end

    context 'variant' do
      it 'should return options text with name' do
        expect(variant.descriptive_name).to eql variant.name + ' - Foo Type: Foo'
      end
    end
  end

  # Regression test for https://github.com/spree/spree/issues/2744
  describe "set_position" do
    it "sets variant position after creation" do
      variant = create(:variant)
      expect(variant.position).to_not be_nil
    end
  end

  describe '#in_stock?' do
    before do
      stub_spree_preferences(track_inventory_levels: true)
    end

    context 'when stock_items are not backorderable' do
      before do
        allow_any_instance_of(Spree::StockItem).to receive_messages(backorderable: false)
      end

      context 'when stock_items in stock' do
        before do
          variant.stock_items.first.update_column(:count_on_hand, 10)
        end

        it 'returns true if stock_items in stock' do
          expect(variant.in_stock?).to be true
        end
      end

      context 'when stock_items out of stock' do
        before do
          allow_any_instance_of(Spree::StockItem).to receive_messages(backorderable: false)
          allow_any_instance_of(Spree::StockItem).to receive_messages(count_on_hand: 0)
        end

        it 'return false if stock_items out of stock' do
          expect(variant.in_stock?).to be false
        end
      end
    end

    describe "#can_supply?" do
      it "calls out to quantifier" do
        expect(Spree::Stock::Quantifier).to receive(:new).and_return(quantifier = double)
        expect(quantifier).to receive(:can_supply?).with(10)
        variant.can_supply?(10)
      end

      context "with a stock_location specified" do
        subject { variant.can_supply?(10, stock_location) }

        let(:quantifier) { instance_double(Spree::Stock::Quantifier) }
        let(:stock_location) { build_stubbed(:stock_location) }

        it "initializes the quantifier with the stock location" do
          expect(Spree::Stock::Quantifier).
            to receive(:new).
            with(variant, stock_location).
            and_return(quantifier)
          allow(quantifier).to receive(:can_supply?).with(10)
          subject
        end
      end
    end

    context 'when stock_items are backorderable' do
      before do
        allow_any_instance_of(Spree::StockItem).to receive_messages(backorderable: true)
      end

      context 'when stock_items out of stock' do
        before do
          allow_any_instance_of(Spree::StockItem).to receive_messages(count_on_hand: 0)
        end

        it 'in_stock? returns false' do
          expect(variant.in_stock?).to be false
        end

        it 'can_supply? return true' do
          expect(variant.can_supply?).to be true
        end
      end
    end

    describe "cache clearing on update" do
      it "correctly reports after updating track_inventory" do
        variant.stock_items.first.set_count_on_hand 0
        expect(variant).not_to be_in_stock

        variant.update!(track_inventory: false)
        expect(variant).to be_in_stock
      end
    end
  end

  describe '#is_backorderable' do
    let(:variant) { build(:variant) }
    subject { variant.is_backorderable? }

    it 'should invoke Spree::Stock::Quantifier' do
      expect_any_instance_of(Spree::Stock::Quantifier).to receive(:backorderable?) { true }
      subject
    end
  end

  describe '#total_on_hand' do
    it 'should be infinite if track_inventory_levels is false' do
      stub_spree_preferences(track_inventory_levels: false)
      expect(build(:variant).total_on_hand).to eql(Float::INFINITY)
    end

    it 'should match quantifier total_on_hand' do
      variant = build(:variant)
      expect(variant.total_on_hand).to eq(Spree::Stock::Quantifier.new(variant).total_on_hand)
    end

    context "with a stock_location specified" do
      subject { variant.total_on_hand(stock_location) }

      let(:quantifier) { instance_double(Spree::Stock::Quantifier) }
      let(:stock_location) { build_stubbed(:stock_location) }

      it "initializes the quantifier with the stock location" do
        expect(Spree::Stock::Quantifier).
          to receive(:new).
          with(variant, stock_location).
          and_return(quantifier)
        allow(quantifier).to receive(:total_on_hand)
        subject
      end
    end
  end

  describe '#tax_category' do
    context 'when tax_category is nil' do
      let(:product) { build(:product) }
      let(:variant) { build(:variant, product: product, tax_category_id: nil) }
      it 'returns the parent products tax_category' do
        expect(variant.tax_category).to eq(product.tax_category)
      end
    end

    context 'when tax_category is set' do
      let(:tax_category) { create(:tax_category) }
      let(:variant) { build(:variant, tax_category: tax_category) }
      it 'returns the tax_category set on itself' do
        expect(variant.tax_category).to eq(tax_category)
      end
    end
  end

  describe "touching" do
    it "updates a product" do
      variant.product.update_column(:updated_at, 1.day.ago)
      variant.touch
      expect(variant.product.reload.updated_at).to be_within(3.seconds).of(Time.current)
    end

    it "clears the in_stock cache key" do
      expect(Rails.cache).to receive(:delete).with(variant.send(:in_stock_cache_key))
      variant.touch
    end
  end

  describe "#should_track_inventory?" do
    it 'should not track inventory when global setting is off' do
      stub_spree_preferences(track_inventory_levels: false)

      expect(build(:variant).should_track_inventory?).to eq(false)
    end

    it 'should not track inventory when variant is turned off' do
      stub_spree_preferences(track_inventory_levels: true)

      expect(build(:on_demand_variant).should_track_inventory?).to eq(false)
    end

    it 'should track inventory when global and variant are on' do
      stub_spree_preferences(track_inventory_levels: true)

      expect(build(:variant).should_track_inventory?).to eq(true)
    end
  end

  describe "#discard" do
    it "discards related stock items and images, but not prices" do
      variant.images = [create(:image)]

      expect(variant.stock_items).not_to be_empty
      expect(variant.prices).not_to be_empty

      variant.discard
      variant.reload

      expect(variant.images).to be_empty
      expect(variant.stock_items.reload).to be_empty
      expect(variant.prices).not_to be_empty
    end

    describe 'default_price' do
      let!(:previous_variant_price) { variant.default_price }

      it "should not discard default_price" do
        variant.discard
        variant.reload
        expect(previous_variant_price.reload).not_to be_discarded
      end

      it "should keep its price if deleted" do
        variant.discard
        variant.reload
        expect(variant.default_price).to eq(previous_variant_price)
      end

      context 'when loading with pre-fetching of default_price' do
        it 'also keeps the previous price' do
          variant.discard
          reloaded_variant = Spree::Variant.with_discarded.find_by(id: variant.id)
          expect(reloaded_variant.default_price).to eq(previous_variant_price)
        end
      end
    end
  end

  describe "stock movements" do
    let!(:movement) { create(:stock_movement, stock_item: variant.stock_items.first) }

    it "builds out collection just fine through stock items" do
      expect(variant.stock_movements.to_a).not_to be_empty
    end
  end

  describe "in_stock scope" do
    subject { Spree::Variant.in_stock }
    let!(:in_stock_variant) { create(:variant) }
    let!(:out_of_stock_variant) { create(:variant) }
    let!(:stock_location) { create(:stock_location) }

    context "a stock location is provided" do
      subject { Spree::Variant.in_stock([stock_location]) }

      context "there's stock in the location" do
        before do
          in_stock_variant.
            stock_items.find_by(stock_location: stock_location).
            update_column(:count_on_hand, 10)
          out_of_stock_variant.
            stock_items.where.not(stock_location: stock_location).first.
            update_column(:count_on_hand, 10)
        end

        it "returns all in stock variants in the provided stock location" do
          expect(subject).to eq [in_stock_variant]
        end
      end

      context "there's no stock in the location" do
        it "returns an empty list" do
          expect(subject).to eq []
        end
      end
    end

    context "a stock location is not provided" do
      before do
        in_stock_variant.stock_items.first.update_column(:count_on_hand, 10)
      end

      it "returns all in stock variants" do
        expect(subject).to eq [in_stock_variant]
      end
    end

    context "inventory levels globally not tracked" do
      before { stub_spree_preferences(track_inventory_levels: false) }

      it 'includes items without inventory' do
        expect( subject ).to include out_of_stock_variant
      end
    end
  end

  describe ".suppliable" do
    subject { Spree::Variant.suppliable }
    let!(:in_stock_variant) { create(:variant) }
    let!(:out_of_stock_variant) { create(:variant) }
    let!(:backordered_variant) { create(:variant) }
    let!(:stock_location) { create(:stock_location) }

    before do
      in_stock_variant.stock_items.update_all(count_on_hand: 10)
      backordered_variant.stock_items.update_all(count_on_hand: 0, backorderable: true)
      out_of_stock_variant.stock_items.update_all(count_on_hand: 0, backorderable: false)
    end

    it "includes the in stock variant" do
      expect( subject ).to include(in_stock_variant)
    end

    it "includes out of stock variant" do
      expect( subject ).to include(backordered_variant)
    end

    it "does not include out of stock variant" do
      expect( subject ).not_to include(out_of_stock_variant)
    end

    it "includes variants only once" do
      expect(subject.to_a.count(in_stock_variant)).to be 1
    end

    context "inventory levels globally not tracked" do
      before { stub_spree_preferences(track_inventory_levels: false) }

      it "includes all variants" do
        expect( subject ).to include(in_stock_variant, backordered_variant, out_of_stock_variant)
      end
    end
  end

  describe "#variant_properties" do
    let(:option_value_1) { create(:option_value) }
    let(:option_value_2) { create(:option_value) }
    let(:variant) { create(:variant, option_values: [option_value_1, option_value_2]) }

    subject { variant.variant_properties }

    context "variant has properties" do
      let!(:rule_1) { create(:variant_property_rule, product: variant.product, option_value: option_value_1, apply_to_all: false) }
      let!(:rule_2) { create(:variant_property_rule, product: variant.product, option_value: option_value_2, apply_to_all: false) }

      it "returns the variant property rule's values" do
        expect(subject).to match_array rule_1.values + rule_2.values
      end
    end

    context "variant doesn't have any properties" do
      it "returns an empty list" do
        expect(subject).to eq []
      end
    end
  end

  describe "#gallery" do
    let(:variant) { build_stubbed(:variant) }
    subject { variant.gallery }

    it "responds to #images" do
      expect(subject).to respond_to(:images)
    end

    context "when variant.images is empty" do
      let(:product) { create(:product) }
      let(:variant) { create(:variant, product: product) }

      it "fallbacks to variant.product.master.images" do
        product.master.images = [create(:image)]

        expect(product.master).not_to eq variant

        expect(variant.gallery.images).to eq product.master.images
      end

      context "and variant.product.master.images is also empty" do
        it "returns Spree::Image.none" do
          expect(product.master).not_to eq variant
          expect(product.master.images.presence).to be nil

          expect(variant.gallery.images).to eq Spree::Image.none
        end
      end

      context "and is master" do
        it "returns Spree::Image.none" do
          variant = product.master

          expect(variant.is_master?).to be true
          expect(variant.images.presence).to be nil

          expect(variant.gallery.images).to eq Spree::Image.none
        end
      end
    end
  end

  describe "#on_backorder" do
    let(:variant) { create(:variant) }

    subject { variant.on_backorder }

    it { is_expected.to be_zero }

    context "with a backordered inventory_unit" do
      let!(:backordered_inventory_unit) { create(:inventory_unit, variant: variant, state: :backordered) }

      it { is_expected.to eq(1) }
    end
  end

  describe "#deleted?" do
    let(:variant) { create(:variant) }

    subject { variant.deleted? }

    it { is_expected.to be false }

    context "if the variant is discarded" do
      before do
        variant.discard
      end

      it { is_expected.to be true }
    end
  end

  describe "#name_and_sku" do
    let(:product) { build(:product, name: "Ernie and Bert" )}
    let(:variant) { build(:variant, product: product, sku: "EB1") }

    subject { variant.name_and_sku }

    it { is_expected.to eq("Ernie and Bert - EB1") }
  end

  describe "#sku_and_options_text" do
    let(:variant) { create(:variant, sku: "EB1") }

    subject { variant.sku_and_options_text }
    it { is_expected.to eq("EB1 Size: S") }
  end
end
