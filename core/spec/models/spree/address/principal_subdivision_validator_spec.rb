# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Address::PrincipalSubdivisionValidator do
  let(:country) { create :country, states_required: true }
  let(:state) { create :state, name: "maryland", abbr: "md", country: }
  let(:address) { build(:address, country:) }

  subject { described_class.new(address).perform }

  describe "state attributes normalization" do
    context "having a country with no states" do
      before do
        address.country = country
        address.principal_subdivision = state
        allow(country).to receive(:states).and_return([])
      end

      it "nullifies the state attr" do
        address.principal_subdivision = state
        expect { subject }.to change(address, :principal_subdivision).from(state).to(nil)
      end
    end

    context "with state_name attr present" do
      before do
        address.country = country
        address.principal_subdivision_name = state_name
      end

      context "and state attr present" do
        let(:state_name) { "A State Name" }

        before do
          address.principal_subdivision = state
        end

        it "nullifies the state_name if the state attr belongs to the country" do
          expect { subject }.to change(address, :principal_subdivision_name).from(state_name).to(nil)
          expect { subject }.to_not change(address, :principal_subdivision).from(state)
        end

        context "belonging to a different country" do
          before do
            allow(state).to receive(:country).and_return(spy(Spree::Country))
          end

          it "doesn't nullify the state name" do
            expect { subject }.to_not change(address, :principal_subdivision_name).from(state_name)
          end
        end
      end

      context "with state_name matching an existing country's state" do
        let(:state_name) { state.name }

        before do
          address.principal_subdivision = nil
        end

        it "sets the state having the specified state name" do
          expect { subject }
            .to change { [address.principal_subdivision, address.principal_subdivision_name] }
            .from([nil, state.name])
            .to([state, nil])
        end
      end
    end
  end

  context "state is not required" do
    shared_examples "no state validation" do
      it "doesn't validate the state presence" do
        address.principal_subdivision = nil
        address.principal_subdivision_name = nil
        subject

        expect(address.errors).to be_empty
      end
    end

    context "address_requires_state preference is false" do
      before do
        stub_spree_preferences(address_requires_state: false)
      end

      include_examples "no state validation"
    end

    context "country does not require state" do
      before do
        country.states_required = false
      end

      include_examples "no state validation"
    end
  end

  context "address requires state" do
    before do
      stub_spree_preferences(address_requires_state: true)
    end

    it "state_name is not nil and country does not have any states" do
      address.principal_subdivision = nil
      address.principal_subdivision_name = "alabama"

      subject

      expect(address.errors).to be_empty
    end

    it "errors when state_name is nil" do
      address.principal_subdivision_name = nil
      address.principal_subdivision = nil

      subject

      expect(address.errors.messages).to eq({principal_subdivision: ["can't be blank"]})
    end

    context "state country doesn't match the address' country" do
      context "with address country having states" do
        let(:italy) { create(:country, iso: "IT", states_required: true) }
        let!(:it_state) { create(:state, country: italy) }
        let(:us_state) { create(:state, country_iso: "US") }

        it "is invalid" do
          address.country = italy
          address.principal_subdivision = us_state

          subject

          expect(address.errors["principal_subdivision"]).to eq(["does not match the country"])
        end
      end
    end
  end
end
