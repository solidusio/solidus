require 'spec_helper'

describe Spree::Core::Search::ProductFilters do
  describe '#partial_path' do
    context 'with no partial path' do
      subject { described_class.new.partial_path }

      it { is_expected.to eql 'spree/shared/sidebar_filters' }
    end

    context 'with empty partial path' do
      subject { -> { described_class.new(partial_path: '').partial_path } }

      it { is_expected.to raise_error /partial_path needs to be set/ }
    end

    context 'with nil partial path' do
      subject { described_class.new(partial_path: other_partial).partial_path }

      let(:other_partial) { 'some/other/partial' }

      it { is_expected.to eql other_partial }
    end
  end

  describe '#all' do
    let(:product_filters) { [Spree::Core::ProductFilters.all_taxons] }

    context 'with no taxon' do
      subject { described_class.new.all }

      it { is_expected.to match_array(product_filters) }
    end

    context 'with nil taxon' do
      subject { described_class.new(taxon: nil).all }

      it { is_expected.to match_array(product_filters) }
    end

    context 'with a taxon' do
      subject { described_class.new(taxon: taxon).all }

      let(:taxon) { build_stubbed(:taxon) }
      let(:taxon_filters) do
        [Spree::Core::ProductFilters.price_filter, Spree::Core::ProductFilters.brand_filter]
      end

      it { is_expected.to match_array(taxon_filters) }
    end
  end
end
