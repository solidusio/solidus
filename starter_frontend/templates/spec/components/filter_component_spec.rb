require "solidus_starter_frontend_spec_helper"

RSpec.describe FilterComponent, type: :component do
  let(:filter) { Spree::Core::ProductFilters.price_filter }
  let(:search_params) { {} }

  let(:inputs) do
    page.all('input')
  end

  context 'when rendered' do
    before do
      render_inline(described_class.new(filter: filter, search_params: search_params))
    end

    it 'renders a list of checkboxes for the filter labels' do
      expect(inputs).to_not be_empty
      expect(inputs.first[:id]).to eq('Price_Range_Under__10.00')
    end

    context 'when a filter list item was checked' do
      let(:search_params) do
        { price_range_any: ["Under $10.00"] }
      end

      it 'renders as checked' do
        expect(inputs.first['checked']).to be_truthy
      end
    end

    context 'when a filter list item was not checked' do
      let(:search_params) { { } }

      it 'renders as unchecked' do
        expect(inputs.first['checked']).to be_falsey
      end
    end
  end
end
