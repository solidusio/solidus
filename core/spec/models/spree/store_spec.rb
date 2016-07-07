require 'spec_helper'

describe Spree::Store, type: :model do
  it { is_expected.to respond_to(:cart_tax_country_iso) }

  describe ".by_url" do
    let!(:store)    { create(:store, url: "website1.com\nwww.subdomain.com") }
    let!(:store_2)  { create(:store, url: 'freethewhales.com') }

    it "should find stores by url" do
      by_domain = Spree::Store.by_url('www.subdomain.com')

      expect(by_domain).to include(store)
      expect(by_domain).not_to include(store_2)
    end
  end

  describe '.current' do
    let!(:store_1) { create(:store) }
    let!(:store_default) { create(:store, name: 'default', default: true) }
    let!(:store_2) { create(:store, default: false, url: 'www.subdomain.com') }
    let!(:store_3) { create(:store, default: false, url: 'www.another.com', code: 'CODE') }

    delegate :current, to: :described_class

    context "with no argument" do
      it 'should return default' do
        Spree::Deprecation.silence do
          expect(current).to eql(store_default)
        end
      end
    end

    context "with no match" do
      it 'should return the default domain' do
        expect(current('foobar.com')).to eql(store_default)
      end
    end

    context "with matching url" do
      it 'should return matching store' do
        expect(current('www.subdomain.com')).to eql(store_2)
      end
    end

    context "with matching code" do
      it 'should return matching store' do
        expect(current('CODE')).to eql(store_3)
      end
    end
  end

  describe ".default" do
    it "should ensure saved store becomes default if one doesn't exist yet" do
      expect(Spree::Store.where(default: true).count).to eq(0)
      store = build(:store)
      expect(store.default).not_to be true

      store.save!

      expect(store.default).to be true
    end

    it "should ensure there is only one default" do
      orig_default_store = create(:store, default: true)
      expect(orig_default_store.reload.default).to be true

      new_default_store = create(:store, default: true)

      expect(Spree::Store.where(default: true).count).to eq(1)

      [orig_default_store, new_default_store].each(&:reload)

      expect(new_default_store.default).to be true
      expect(orig_default_store.default).not_to be true
    end
  end

  describe '#default_cart_tax_location' do
    subject { described_class.new(cart_tax_country_iso: cart_tax_country_iso) }
    context "when there is no cart_tax_country_iso set" do
      let(:cart_tax_country_iso) { '' }
      it "responds with an empty default_cart_tax_location" do
        expect(subject.default_cart_tax_location).to be_empty
      end
    end

    context "when there is a cart_tax_country_iso set" do
      let(:country) { create(:country, iso: "DE") }
      let(:cart_tax_country_iso) { country.iso }

      it "responds with a default_cart_tax_location with that country" do
        expect(subject.default_cart_tax_location).to eq(Spree::Tax::TaxLocation.new(country: country))
      end
    end
  end
end
