require 'spec_helper'

describe Solidus::Store, :type => :model do

  describe ".by_url" do
    let!(:store)    { create(:store, url: "website1.com\nwww.subdomain.com") }
    let!(:store_2)  { create(:store, url: 'freethewhales.com') }

    it "should find stores by url" do
      by_domain = Solidus::Store.by_url('www.subdomain.com')

      expect(by_domain).to include(store)
      expect(by_domain).not_to include(store_2)
    end
  end

  describe '.current' do
    # there is a default store created with the test_app rake task.
    let!(:store_1) { Solidus::Store.first || create(:store) }

    let!(:store_2) { create(:store, default: false, url: 'www.subdomain.com') }
    let!(:store_3) { create(:store, default: false, url: 'www.another.com', code: 'CODE')}

    it 'should return default when no domain' do
      expect(subject.class.current).to eql(store_1)
    end

    it 'should return store for domain' do
      expect(subject.class.current('soliduscommerce.com')).to eql(store_1)
      expect(subject.class.current('www.subdomain.com')).to eql(store_2)
    end

    it 'should return store by code' do
      expect(subject.class.current('CODE')).to eql(store_3)
    end
  end

  describe ".default" do
    let!(:store)    { create(:store) }
    let!(:store_2)  { create(:store, default: true) }

    it "should ensure there is a default if one doesn't exist yet" do
      expect(store_2.default).to be true
    end

    it "should ensure there is only one default" do
      [store, store_2].each(&:reload)

      expect(Solidus::Store.where(default: true).count).to eq(1)
      expect(store_2.default).to be true
      expect(store.default).not_to be true
    end
  end

end
