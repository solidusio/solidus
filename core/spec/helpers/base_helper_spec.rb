require 'spec_helper'

describe Spree::BaseHelper, :type => :helper do
  include Spree::BaseHelper

  let(:product) { create(:product) }
  let(:currency) { 'USD' }

  before do
    allow(helper).to receive(:current_currency) { currency }
  end

  context "available_countries" do
    let(:country) { create(:country) }

    before do
      3.times { create(:country) }
    end

    context "with no checkout zone defined" do
      before do
        Spree::Config[:checkout_zone] = nil
      end

      it "return complete list of countries" do
        expect(available_countries.count).to eq(Spree::Country.count)
      end
    end

    context "with a checkout zone defined" do
      context "checkout zone is of type country" do
        before do
          @country_zone = create(:zone, :name => "CountryZone")
          @country_zone.members.create(:zoneable => country)
          Spree::Config[:checkout_zone] = @country_zone.name
        end

        it "return only the countries defined by the checkout zone" do
          expect(available_countries).to eq([country])
        end
      end

      context "checkout zone is of type state" do
        before do
          state_zone = create(:zone, :name => "StateZone")
          state = create(:state, :country => country)
          state_zone.members.create(:zoneable => state)
          Spree::Config[:checkout_zone] = state_zone.name
        end

        it "return complete list of countries" do
          expect(available_countries.count).to eq(Spree::Country.count)
        end
      end
    end
  end

  # Regression test for https://github.com/spree/spree/issues/1436
  context "defining custom image helpers" do
    let(:product) { mock_model(Spree::Product, :images => [], :variant_images => []) }
    before do
      Spree::Image.class_eval do
        attachment_definitions[:attachment][:styles].merge!({:very_strange => '1x1'})
      end
    end

    it "should not raise errors when style exists" do
      ActiveSupport::Deprecation.silence do
        very_strange_image(product)
      end
    end

    it "should raise NoMethodError when style is not exists" do
      expect { another_strange_image(product) }.to raise_error(NoMethodError)
    end
  end

  # Regression test for https://github.com/spree/spree/issues/5384
  context "custom image helpers conflict with inproper statements" do
    let(:product) { mock_model(Spree::Product, :images => [], :variant_images => []) }
    before do
      Spree::Image.class_eval do
        attachment_definitions[:attachment][:styles].merge!({:foobar => '1x1'})
      end
    end

    it "should not raise errors when helper method called" do
      ActiveSupport::Deprecation.silence do
        foobar_image(product)
      end
    end

    it "should raise NoMethodError when statement with name equal to style name called" do
      expect { foobar(product) }.to raise_error(NoMethodError)
    end

  end

  context "pretty_time" do
    it "prints in a format" do
      expect(pretty_time(DateTime.new(2012, 5, 6, 13, 33))).to eq "May 06, 2012  1:33 PM"
    end
  end

  context "#variant_price_diff" do
    let(:product_price) { 10 }
    let(:variant_price) { 10 }

    before do
      @variant = create(:variant, :product => product)
      product.price = 15
      @variant.price = 10
      allow(product).to receive(:amount_in) { product_price }
      allow(@variant).to receive(:amount_in) { variant_price }
    end

    subject { helper.variant_price(@variant) }

    context "when variant is same as master" do
      it { is_expected.to be_nil }
    end

    context "when the master has no price" do
      let(:product_price) { nil }

      it { is_expected.to be_nil }
    end

    context "when currency is default" do
      context "when variant is more than master" do
        let(:variant_price) { 15 }

        it { is_expected.to eq("(Add: $5.00)") }
        # Regression test for https://github.com/spree/spree/issues/2737
        it { is_expected.to be_html_safe }
      end

      context "when variant is less than master" do
        let(:product_price) { 15 }

        it { is_expected.to eq("(Subtract: $5.00)") }
      end
    end

    context "when currency is JPY" do
      let(:variant_price) { 100 }
      let(:product_price) { 100 }
      let(:currency) { 'JPY' }

      context "when variant is more than master" do
        let(:variant_price) { 150 }

        it { is_expected.to eq("(Add: &#x00A5;50)") }
      end

      context "when variant is less than master" do
        let(:product_price) { 150 }

        it { is_expected.to eq("(Subtract: &#x00A5;50)") }
      end
    end
  end

  context "#variant_price_full" do
    before do
      Spree::Config[:show_variant_full_price] = true
      @variant1 = create(:variant, :product => product)
      @variant2 = create(:variant, :product => product)
    end

    context "when currency is default" do
      it "should return the variant price if the price is different than master" do
        product.price = 10
        @variant1.price = 15
        @variant2.price = 20
        expect(helper.variant_price(@variant1)).to eq("$15.00")
        expect(helper.variant_price(@variant2)).to eq("$20.00")
      end
    end

    context "when currency is JPY" do
      let(:currency) { 'JPY' }

      before do
        product.variants.active.each do |variant|
          variant.prices.each do |price|
            price.currency = currency
            price.save!
          end
        end
      end

      it "should return the variant price if the price is different than master" do
        product.price = 100
        @variant1.price = 150
        expect(helper.variant_price(@variant1)).to eq("&#x00A5;150")
      end
    end

    it "should be nil when all variant prices are equal" do
      product.price = 10
      @variant1.default_price.update_column(:amount, 10)
      @variant2.default_price.update_column(:amount, 10)
      expect(helper.variant_price(@variant1)).to be_nil
      expect(helper.variant_price(@variant2)).to be_nil
    end
  end
end
