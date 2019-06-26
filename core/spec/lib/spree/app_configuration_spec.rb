# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::AppConfiguration do
  let(:prefs) { Spree::Config }

  around do |example|
    with_unfrozen_spree_preference_store do
      example.run
    end
  end

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

  it "uses variant price selector class by default" do
    expect(prefs.variant_price_selector_class).to eq Spree::Variant::PriceSelector
  end

  it "has a getter for the pricing options class provided by the variant price selector class" do
    expect(prefs.pricing_options_class).to eq Spree::Variant::PriceSelector.pricing_options_class
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

  describe '@admin_vat_country_iso' do
    it 'is `nil` by default' do
      expect(prefs[:admin_vat_country_iso]).to eq(nil)
    end
  end

  describe '#environment' do
    class DummyClass; end;

    subject(:environment) { prefs.environment }
    it { is_expected.to be_a Spree::Core::Environment }

    shared_examples "working preferences set" do
      it "allows adding new items" do
        preferences_set << DummyClass
        expect(preferences_set).to include DummyClass
        preferences_set.delete DummyClass
      end
    end

    context '.payment_methods' do
      subject(:preferences_set) { environment.payment_methods }
      it_should_behave_like "working preferences set"
    end

    context '.stock_splitters' do
      subject(:preferences_set) { environment.stock_splitters }
      it_should_behave_like "working preferences set"
    end

    context '.calculators' do
      subject(:calculators) { environment.calculators }
      it { is_expected.to be_a Spree::Core::Environment::Calculators }

      context '.calculators.shipping_methods' do
        subject(:preferences_set) { calculators.shipping_methods }
        it_should_behave_like "working preferences set"
      end

      context '.calculators.tax_rates' do
        subject(:preferences_set) { calculators.tax_rates }
        it_should_behave_like "working preferences set"
      end

      context '.calculators.promotion_actions_create_adjustments' do
        subject(:preferences_set) { calculators.promotion_actions_create_adjustments }
        it_should_behave_like "working preferences set"
      end

      context '.calculators.promotion_actions_create_item_adjustments' do
        subject(:preferences_set) { calculators.promotion_actions_create_item_adjustments }
        it_should_behave_like "working preferences set"
      end

      context '.calculators.promotion_actions_create_quantity_adjustments' do
        subject(:preferences_set) { calculators.promotion_actions_create_quantity_adjustments }
        it_should_behave_like "working preferences set"
      end
    end

    context '.promotions' do
      subject(:promotions) { environment.promotions }
      it { is_expected.to be_a Spree::Core::Environment::Promotions }

      context '.promotions.rules' do
        subject(:preferences_set) { promotions.rules }
        it_should_behave_like "working preferences set"
      end

      context '.promotions.actions' do
        subject(:preferences_set) { promotions.actions }
        it_should_behave_like "working preferences set"
      end

      context '.promotions.shipping_actions' do
        subject(:preferences_set) { promotions.shipping_actions }
        it_should_behave_like "working preferences set"
      end
    end
  end

  it 'has a default admin VAT location with nil values by default' do
    expect(prefs.admin_vat_location).to eq(Spree::Tax::TaxLocation.new)
    expect(prefs.admin_vat_location.state_id).to eq(nil)
    expect(prefs.admin_vat_location.country_id).to eq(nil)
  end

  it 'has default Event adapter' do
    expect(prefs.events.adapter).to eq Spree::Event::Adapters::ActiveSupportNotifications
  end
end
