# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::StateBlueprint, type: :blueprint do
  let(:result) { described_class.render_as_hash(state, **options) }
  let(:state) { create(:state) }

  describe "default" do
    let(:options) { {} }

    it "returns correct data" do
      expect(result).to eq(id: state.id, name: state.name)
    end
  end

  describe "state_with_country" do
    let(:options) { { view: :state_with_country } }

    it "returns correct data" do
      expect(result).to eq(id: state.id, name: state.state_with_country)
    end

    it "uses cached result" do
      described_class.render_as_hash(state, **options)
      state.reload
      expect { described_class.render_as_hash(state, **options) }.to make_database_queries(count: 0)
    end
  end
end
