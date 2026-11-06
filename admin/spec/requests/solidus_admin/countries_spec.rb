# frozen_string_literal: true

require "spec_helper"
require "solidus_admin/testing_support/shared_examples/json_endpoint_requests"

RSpec.describe "SolidusAdmin::CountriesController", type: :request do
  describe "GET /country/:country_id/states" do
    subject {
      get solidus_admin.country_states_path(country_id: country.id)
      response
    }

    let(:country) { create :country }

    include_examples "JSON endpoint requests",
      method: :get,
      admin_path: :country_states_path do
      let(:path_params) { {country_id: country.id} }
    end

    context "when authenticated as a limited admin user" do
      context "who does not have permission to administrate countries" do
        let(:user) {
          create :limited_admin_user,
            permissions: [Spree::PermissionSets::ProductDisplay]
        }

        it "responds as forbidden" do
          expect(subject).to have_http_status :forbidden
        end

        it "responds in JSON format" do
          expect(subject.content_type).to match(/^application\/json/)
        end
      end

      context "who has permission to administrate countries" do
        let(:user) {
          create :limited_admin_user,
            permissions: [Spree::PermissionSets::ConfigurationDisplay]
        }

        let!(:state) { create :state, name: "Illinois", country: country }

        it "responds in JSON format" do
          expect(subject.content_type).to match(/^application\/json/)
        end

        it "serves JSON with a 200 OK status" do
          expect(subject).to have_http_status(:ok)
          expect(JSON.parse(subject.body)).to contain_exactly(
            "id" => state.id,
            "name" => "Illinois"
          )
        end
      end
    end
  end
end
