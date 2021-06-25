# frozen_string_literal: true

require 'spec_helper'

module Spree
  describe Api::StatesController, type: :request do
    let!(:state) { create(:state, name: "Victoria") }
    let(:attributes) { [:id, :name, :abbr, :country_id] }

    before do
      stub_authentication!
    end

    it "gets all states" do
      get spree.api_states_path
      expect(json_response["states"].first).to have_attributes(attributes)
      expect(json_response['states'].first['name']).to eq(state.name)
    end

    it "gets all the states for a particular country" do
      get spree.api_country_states_path(state.country)
      expect(json_response["states"].first).to have_attributes(attributes)
      expect(json_response['states'].first['name']).to eq(state.name)
    end

    context "pagination" do
      it "can select the next page and control page size" do
        create(:state)
        get spree.api_states_path, params: { page: 2, per_page: 1 }

        expect(json_response).to be_paginated
        expect(json_response["states"].size).to eq(1)
        expect(json_response["pages"]).to eq(2)
        expect(json_response["current_page"]).to eq(2)
        expect(json_response["count"]).to eq(1)
      end
    end

    context "with two states" do
      before { create(:state, name: "New South Wales") }

      it "gets all states for a country" do
        country = create(:country, states_required: true)
        state.country = country
        state.save

        get spree.api_country_states_path(country)
        expect(json_response["states"].first).to have_attributes(attributes)
        expect(json_response["states"].count).to eq(1)
        json_response["states_required"] = true
      end

      it "can view all states" do
        get spree.api_states_path
        expect(json_response["states"].first).to have_attributes(attributes)
      end

      it 'can query the results through a paramter' do
        get spree.api_states_path, params: { q: { name_cont: 'Vic' } }
        expect(json_response['states'].first['name']).to eq("Victoria")
      end
    end

    it "can view a state" do
      get spree.api_state_path(state)
      expect(json_response).to have_attributes(attributes)
    end
  end
end
