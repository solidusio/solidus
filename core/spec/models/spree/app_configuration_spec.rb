require 'spec_helper'

describe Spree::AppConfiguration, type: :model do
  let(:prefs) { Rails.application.config.spree.preferences }

  it "should be available from the environment" do
    prefs.layout = "my/layout"
    expect(prefs.layout).to eq "my/layout"
  end

  it "should be available as Spree::Config for legacy access" do
    expect(Spree::Config).to be_a Spree::AppConfiguration
  end

  it "uses base searcher class by default" do
    expect(prefs.searcher_class).to eq Spree::Core::Search::Base
  end

  it "uses variant search class by default" do
    expect(prefs.variant_search_class).to eq Spree::Core::Search::Variant
  end

  describe '@can_restrict_stock_management' do
    # Ensure we start with a clean configuration
    before do
      Spree::RoleConfiguration.instance.send :initialize
      Spree::RoleConfiguration.configure do |config|
        config.assign_permissions :default, [Spree::PermissionSets::DefaultCustomer]
        config.assign_permissions :admin, [Spree::PermissionSets::SuperUser]
      end
    end

    it 'defaults to false normally' do
      expect( prefs.can_restrict_stock_management ).to be false
    end

    it 'defaults to true if using any of the restricted stock management permission sets' do
      Spree::RoleConfiguration.configure do |config|
        config.assign_permissions :test_restrict, [Spree::PermissionSets::RestrictedStockDisplay]
      end
      expect( prefs.can_restrict_stock_management ).to be true
    end
  end

  describe '#stock' do
    subject { prefs.stock }
    it { is_expected.to be_a Spree::Core::StockConfiguration }
  end

  describe '@default_country_iso_code' do
    it 'is the USA by default' do
      expect(prefs[:default_country_iso]).to eq("US")
    end
  end
end
