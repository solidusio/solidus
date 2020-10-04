# frozen_string_literal: true

require 'rails_helper'

module Spree
  RSpec.describe Core::Search::Variant do
    def assert_found(query_string, variant)
      expect(described_class.new(query_string).results).to include variant
    end

    def refute_found(query_string, variant)
      expect(described_class.new(query_string).results).not_to include variant
    end

    let(:product) { FactoryBot.create(:product, name: "My Special Product", slug: "my-special-product") }
    let!(:variant) { FactoryBot.create(:variant, product: product, sku: "abc-123") }

    context "blank string" do
      it { assert_found(nil, variant) }
      it { assert_found("", variant) }
    end

    context "by sku" do
      it { assert_found("abc-123", variant) }
      it { assert_found("abc-1", variant) }
      it { assert_found("aBc-12", variant) }
      it { refute_found("bca", variant) }
    end

    context "by product" do
      it { assert_found("My Special Product", variant) }
      it { assert_found("My Spec", variant) }
      it { assert_found("my spec", variant) }
      it { assert_found("my-special-product", variant) }
      it { assert_found("my-spec", variant) }
      it { assert_found("mY-sPec", variant) }
      it { assert_found("My Product", variant) }
      it { refute_found("My House", variant) }
      it { refute_found("my-product", variant) }
    end

    context "by product + options" do
      before do
        variant.option_values << create(:option_value, presentation: "Robin's egg", name: "blue")
        variant.option_values << create(:option_value, presentation: 'Slim')
        variant.option_values << create(:option_value, presentation: '30')
      end
      it { assert_found("My Spec blue", variant) }
      it { assert_found("My Spec robin egg Slim", variant) }
      it { assert_found("My Spec 30 slim", variant) }
      it { refute_found("My Spec red slim", variant) }
      it { refute_found("foo product blue slim", variant) }
    end

    context "custom scope" do
      it "takes into account a passed in scope" do
        variant.stock_items.first.set_count_on_hand(10)
        expect(
          described_class.new(variant.sku, scope: Spree::Variant.in_stock).results
        ).to include variant

        variant.stock_items.each { |si| si.set_count_on_hand(0) }
        expect(
          described_class.new(variant.sku, scope: Spree::Variant.in_stock).results
        ).not_to include variant
      end
    end

    context "custom search configuration" do
      context "removing a search query" do
        around do |example|
          search_terms = described_class.search_terms
          described_class.search_terms -= [:sku_cont]
          example.run
          described_class.search_terms = search_terms
        end

        it { refute_found("abc-123", variant) }
      end

      context "adding a search query" do
        around do |example|
          search_terms = described_class.search_terms
          described_class.search_terms += [:weight_eq]
          example.run
          described_class.search_terms = search_terms
        end
        before { variant.update!(weight: 5000) }

        it { assert_found("5000", variant) }
      end
    end

    describe '#search_terms' do
      # Only search by SKU if the search word is a number
      class NumericSkuSearcher < Core::Search::Variant
        protected

        def search_terms(word)
          if word =~ /\A\d+\z/
            super
          else
            super - [:sku_cont]
          end
        end
      end

      let!(:numeric_sku_variant) { FactoryBot.create(:variant, product: product, sku: "123") }
      let!(:non_numeric_sku_variant) { FactoryBot.create(:variant, product: product, sku: "abc") }

      it { expect(NumericSkuSearcher.new('123').results).to include numeric_sku_variant }
      it { expect(NumericSkuSearcher.new('abc').results).not_to include non_numeric_sku_variant }
    end
  end
end
