# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::State, type: :model do
  describe '.with_name_or_abbr' do
    subject do
      Spree::State.with_name_or_abbr(search_term)
    end

    let!(:state) { create(:state, name: "California", abbr: "CA") }

    context 'by invalid term' do
      let(:search_term) { 'NonExistent' }
      it { is_expected.to be_empty }
    end

    context 'by name' do
      let(:search_term) { 'California' }
      it { is_expected.to include(state) }
    end

    context 'by abbr' do
      let(:search_term) { 'CA' }
      it { is_expected.to include(state) }
    end

    context 'by case-insensitive abbr' do
      let(:search_term) { 'CaLiFoRnIa' }
      it { is_expected.to include(state) }
    end

    context 'by case-insensitive abbr' do
      let(:search_term) { 'cA' }
      it { is_expected.to include(state) }
    end
  end

  it "can find all states group by country id" do
    state = create(:state)
    expect(Spree::State.states_group_by_country_id).to eq({ state.country_id.to_s => [[state.id, state.name]] })
  end
end
