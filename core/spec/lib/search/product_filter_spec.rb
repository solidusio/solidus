require 'spec_helper'

describe Spree::Core::Search::ProductFilter do
  describe '.partial_path' do
    subject { described_class.partial_path }

    it { is_expected.to eql 'spree/shared/sidebar_filters' }
  end

  describe '#filters' do
    let(:product_filters) { [Spree::Core::ProductFilters.all_taxons] }

    context 'with no taxon' do
      subject { described_class.new.filters }

      it { is_expected.to match_array(product_filters) }
    end

    context 'with nil taxon' do
      subject { described_class.new(nil).filters }

      it { is_expected.to match_array(product_filters) }
    end

    context 'with a taxon' do
      subject { described_class.new(taxon).filters }

      let(:taxon) { build_stubbed(:taxon) }
      let(:taxon_filters) do
        [Spree::Core::ProductFilters.price_filter, Spree::Core::ProductFilters.brand_filter]
      end

      it { is_expected.to match_array(taxon_filters) }
    end
  end
end
