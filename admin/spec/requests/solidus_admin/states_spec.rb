# frozen_string_literal: true

require "spec_helper"
require "solidus_admin/testing_support/shared_examples/json_endpoint_requests"

RSpec.describe "SolidusAdmin::StatesController", type: :request do
  before do
    allow_any_instance_of(SolidusAdmin::BaseController)
      .to receive(:spree_current_user)
      .and_return(user)
  end

  describe "GET /index" do
    include_examples "JSON endpoint requests",
      method: :get,
      admin_path: :states_path

    context "when authenticated as a limited admin user" do
      context "who does not have permission to administrate states" do
        let(:user) {
          create :limited_admin_user,
            permissions: [Spree::PermissionSets::ProductDisplay]
        }

        it "responds as forbidden" do
          get solidus_admin.states_path

          expect(response).to have_http_status :forbidden
        end

        it "responds in JSON format" do
          get solidus_admin.states_path

          expect(response.content_type).to match(/^application\/json/)
        end
      end

      context "who has permission to administrate states" do
        let(:user) {
          create :limited_admin_user,
            permissions: [Spree::PermissionSets::ConfigurationDisplay]
        }

        before do
          create_list(:state, 3)
        end

        it "responds in JSON format" do
          get solidus_admin.states_path

          expect(response.content_type).to match(/^application\/json/)
        end

        it "serves JSON with a 200 OK status" do
          get solidus_admin.states_path

          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body).size).to eq(3)
        end

        context "with pagination" do
          it "links to the next page while more states remain" do
            allow_any_instance_of(SolidusAdmin::StatesController)
              .to receive(:per_page)
              .and_return(2)

            get solidus_admin.states_path(view: "state_with_country")

            expect(response.headers["X-Total-Count"]).to eq("3")
            expect(response.headers["Link"]).to eq(
              %(<http://www.example.com/admin/states?page=2&view=state_with_country>; rel="next")
            )
          end

          it "sends no next link on the last page" do
            allow_any_instance_of(SolidusAdmin::StatesController)
              .to receive(:per_page)
              .and_return(3)

            get solidus_admin.states_path

            expect(response.headers["X-Total-Count"]).to eq("3")
            expect(response.headers["Link"]).to be_nil
          end
        end
      end
    end
  end
end
