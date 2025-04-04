# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::Stores::AddressForm::Component, type: :component do
  let(:country) { create(:country, states_required: true) }
  let(:state) { create(:state, country: country) }
  let(:store) { create(:store, country: country, state: state) }

  subject(:component) { described_class.new(store: store) }

  describe "#state_options" do
    context "when the country has states and requires states" do
      it "returns a list of state names and IDs" do
        expect(component.state_options).to include([state.name, state.id])
      end
    end

    context "when the country does not require states" do
      let(:country) { create(:country, states_required: false) }

      it "returns an empty array" do
        expect(component.state_options).to eq([])
      end
    end

    context "when there is no country assigned to the store" do
      let(:store) { create(:store, country: nil) }

      it "returns an empty array" do
        expect(component.state_options).to eq([])
      end
    end
  end
end
